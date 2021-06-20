require 'action_view'
require 'active_support'

module Editmode
  class ChunkValue
    include ActionView::Helpers::TagHelper
    include ActionView::Context

    attr_accessor :identifier, :variable_values, :branch_id,
      :variable_fallbacks, :chunk_type, :project_id,
      :url, :collection_id, :cache_identifier,
      :response, :transformation

    attr_writer :content

    def initialize(identifier, project_id: Editmode.project_id, **options)
      @identifier = identifier
      @branch_id = options[:branch_id].presence
      @project_id = project_id
      @referrer = options[:referrer].presence || ""
      @variable_values = options[:variables].presence || {}
      @raw = options[:raw].present?
      @skip_sanitize = options[:dangerously_skip_sanitization]
      @skip_cache = options[:skip_cache]
      @transformation = options[:transformation]

      @url = "#{api_root_url}/chunks/#{identifier}"
      @cache_identifier = set_cache_identifier(identifier)

      if options[:response].present?
        @response = options[:response]
        set_response_attributes!
      else
        get_content
      end
    end

    def field(field = nil)
      # Field ID can be a slug or field_name
      if chunk_type == 'collection_item'
        if field.present?
          field_chunk = field_chunk(field)
          if field_chunk.present?
            result = field_chunk['chunk_type'] == 'image' ? set_transformation_properties!(field_chunk['content']) : field_chunk['content']
            result = variable_parse!(result, variable_fallbacks, variable_values, @raw, @skip_sanitize)
          else
            raise no_response_received(field)
          end
        else
          raise require_field_id
        end
      else
        raise "undefined method 'field` for chunk_type: #{chunk_type} \n"
      end
      result ||= @content
      result.try(:html_safe)
    end

    def field_chunk(field)
      field.downcase!
      @content.detect {|f| f["custom_field_identifier"].downcase == field || f["custom_field_name"].downcase == field }
    end

    def content
      raise "undefined method 'content' for chunk_type: collection_item \nDid you mean? field" if chunk_type == 'collection_item'

      result = variable_parse!(@content, variable_fallbacks, variable_values, @raw, @skip_sanitize)
      result.try(:html_safe)
    end

    def cached?
      return false if @skip_cache
      Rails.cache.exist?(cache_identifier)
    end

    private
    def set_transformation_properties!(url)
      if transformation.present? && url.present?
        transformation.gsub!(" ", ",")
        transformation.gsub!(/\s/, '')
  
        uri = URI(url)
        uri.query = [uri.query, "tr=#{transformation}"].compact.join("&")
        
        url = uri.to_s
      end

      url
    end

    def allowed_tag_attributes
      %w(style href title src alt width height class target)
    end

    # Todo: Transfer to helper utils
    def api_root_url
      ENV["EDITMODE_OVERRIDE_API_URL"] || "https://api2.editmode.com"
    end

    def set_cache_identifier(id)
      "chunk_#{project_id}#{branch_id}#{id}"
    end

    def json?(json)
      JSON.parse(json)
      return true
    rescue JSON::ParserError => e
      return false
    end

    def variable_parse!(content, variables = {}, values = {}, raw = true, skip_sanitize=false)
      tokens = content.scan(/\{{(.*?)\}}/)
      if tokens.any?
        tokens.flatten!
        tokens.each do |token|
          token_value = values[token.to_sym] || variables[token] || ""
          sanitized_value = ActionController::Base.helpers.sanitize(token_value)

          unless raw
            sanitized_value = content_tag("em-var", :data => {chunk_variable: token, chunk_variable_value: sanitized_value}) do
              sanitized_value
            end
          end

          content.gsub!("{{#{token}}}", sanitized_value)
        end
      end

      content = ActionController::Base.helpers.sanitize(content, attributes: allowed_tag_attributes) unless skip_sanitize
      return content
    end

    def query_params
      p = { project_id: project_id }
      p[:branch_id] = branch_id if branch_id.present?
      p[:referrer] = @referrer if @referrer.present?
      p
    end

    def get_content
      if !cached?
        @response = HTTParty.get(url, query: query_params)
        response_received = true if @response.code == 200
      end

      if !cached? && !response_received
        message = @response.try(:[], 'message') || no_response_received(identifier)

        raise message
      else
        Rails.cache.write(cache_identifier, @response.to_json) if @response.present?
        cached_response = Rails.cache.fetch(cache_identifier)

        if cached_response.present?
          @response = json?(cached_response) ? JSON.parse(cached_response) : cached_response
        end

        set_response_attributes!
      end
    end

    def set_response_attributes!
      @chunk_type = response['chunk_type']
      
      @content = @chunk_type == 'image' ? set_transformation_properties!(response['content']) : response['content'] 
      @variable_fallbacks = response['variable_fallbacks'].presence || {}
      @collection_id = response["collection"]["identifier"] if chunk_type == 'collection_item'
      @branch_id = response['branch_id']
    end

    def no_response_received(id = "")
      "Sorry, we can't find a chunk using this identifier: \"#{id}\". This can happen if you've deleted a chunk on editmode.com or if your local cache is out of date. If it persists, try running Rails.cache clear."
    end
  end
end
