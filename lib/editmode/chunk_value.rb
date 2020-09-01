module Editmode
  class ChunkValue
    include Editmode::ActionViewExtensions::EditmodeHelper

    attr_accessor :identifier, :variable_values, :branch_id, 
                  :variable_fallbacks, :chunk_type, :project_id, 
                  :response

    attr_writer :content

    def initialize(identifier, **options)
      @identifier = identifier
      @branch_id = options[:branch_id].presence
      @variable_values = options[:values].presence || {}
      get_content
    end

    def field(field = nil)
      # Field ID can be a slug or field_name
      if chunk_type == 'collection_item'
        if field.present?
          field.downcase!
          field_content = @content.detect {|f| f["custom_field_identifier"].downcase == field || f["custom_field_name"].downcase == field }
          if field_content.present?
            result = field_content['content']
            result = variable_parse!(result, variable_fallbacks, variable_values)
          else
            raise no_response_received(field)
          end
        else
          raise require_field_id
        end
      else
        raise NoMethodError.new "undefined method 'field` for chunk_type: #{chunk_type} \n"
      end
      result || @content
    end

    def content
      raise NoMethodError.new "undefined method 'content` for chunk_type: collection_item \nDid you mean? field" if chunk_type == 'collection_item'
      
      variable_parse!(@content, variable_fallbacks, variable_values)
    end

    private
    def get_content
      branch_params = branch_id.present? ? "branch_id=#{branch_id}" : ""
      url = "#{api_root_url}/chunks/#{identifier}?project_id=#{Editmode.project_id}&#{branch_params}"

      cache_identifier = "chunk_value_#{identifier}#{branch_id}"
      cached_content_present = Rails.cache.exist?(cache_identifier)

      if !cached_content_present
        http_response = HTTParty.get(url)
        response_received = true if http_response.code == 200
      end

      if !cached_content_present && !response_received
        raise no_response_received(identifier)
      else
        @response = Rails.cache.fetch(cache_identifier) do
          http_response
        end

        @content = response['content']
        @chunk_type = response['chunk_type']
        @project_id = response['project_id']
        @variable_fallbacks = Rails.cache.fetch("chunk_#{project_id}_variables") do
          response['variable_fallbacks']
        end
      end      
    end

  end
end