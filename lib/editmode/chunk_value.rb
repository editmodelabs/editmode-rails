module Editmode
  class ChunkValue
    include Editmode::ActionViewExtensions::EditmodeHelper

    attr_accessor :identifier, :variable_values, :branch_id, 
                  :variable_fallbacks, :chunk_type, :project_id, 
                  :content

    def initialize(identifier, **options)
      @identifier = identifier
      @branch_id = options[:branch_id].presence
      @project_id = options[:project_id].presence
      @variable_values = options[:values].presence || {}
      get_content
    end

    def field(field = nil)
      # Field ID can be a slug or field_name
      if chunk_type == 'collection_item'
        if field.present?
          field_content = content.detect {|f| f["custom_field_identifier"] == field || f["custom_field_name"] == field }
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
        raise "undefined method field for chunk_type: #{chunk_type}"
      end
      result ||= content
    end

    private
    def get_content
      branch_params = branch_id.present? ? "branch_id=#{branch_id}" : ""
      url = "#{api_root_url}/chunks/#{identifier}?#{branch_params}"

      cache_identifier = "chunk_#{identifier}#{branch_id}"
      cached_content_present = Rails.cache.exist?(cache_identifier)
      cached_content_present = Rails.cache.exist?("chunk_#{project_id || identifier}_variables") if cached_content_present

      if !cached_content_present
        response = HTTParty.get(url)
        response_received = true if response.code == 200
      end

      if !cached_content_present && !response_received
        raise no_response_received(identifier)
      else
        @content = Rails.cache.fetch(cache_identifier) do
          response['content']
        end

        @chunk_type = Rails.cache.fetch("#{cache_identifier}_type") do
          response['chunk_type']
        end

        # Since variables are defined in the project level,
        # We use project_id as cache identifier
        @variable_fallbacks = Rails.cache.fetch("chunk_#{}_variables") do
          response['variable_fallbacks']
        end
      end      
    end

  end
end