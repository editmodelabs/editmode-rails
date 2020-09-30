require 'editmode/helper'

module Editmode
  module ActionViewExtensions
    module EditmodeHelper
      require 'httparty'
      include Editmode::Helper

      def api_version
        # Todo Add Header Version
      end

      def api_root_url
        ENV["EDITMODE_OVERRIDE_API_URL"] || "https://api.editmode.com"
      end

      def chunk_collection(collection_identifier, **options, &block)
        branch_params = params[:em_branch_id].present? ? "branch_id=#{params[:em_branch_id]}" : ""
        branch_id = params[:em_branch_id].presence
        tags = options[:tags].presence || []
        limit = options[:limit].presence
        
        begin 
          url_params = { 
            :collection_identifier => collection_identifier,
            :branch_id => branch_id,
            :limit => limit,
            :tags => tags
          }.to_query

          url = URI(api_root_url)
          url.path = '/chunks'
          url.query = url_params

          cache_identifier = "collection_#{collection_identifier}#{branch_id}#{limit}#{tags.join}"
          cached_content_present = Rails.cache.exist?(cache_identifier)
          
          if !cached_content_present
            response = HTTParty.get(url)
            response_received = true if response.code == 200
          end
          
          if !cached_content_present && !response_received
            raise "No response received"
          else

            chunks = Rails.cache.fetch(cache_identifier) do  
              response['chunks']
            end

            if chunks.any?

              content_tag :div, class: "chunks-collection-wrapper", data: {chunk_collection_identifier: collection_identifier} do
                chunks.each do |chunk|
                  @custom_field_chunk = chunk
                  concat(content_tag(:div, class: "chunks-collection-item--wrapper") do
                    yield
                  end)
                end

                # Placeholder element for new collection item
                @custom_field_chunk = chunks.first.merge!({placeholder: true})
                concat(content_tag(:div, class: "chunks-hide chunks-col-placeholder-wrapper") do
                  yield
                end)
              end 
            end
          end
        rescue => error
          puts error 
          return []
        end
      end
      alias_method :c, :chunk_collection

      def chunk_field_value(parent_chunk_object, custom_field_identifier, options = {})
        begin 
          chunk_identifier = parent_chunk_object["identifier"]
          custom_field_item = parent_chunk_object["content"].detect do |f|
            f["custom_field_identifier"].try(:downcase) == custom_field_identifier.try(:downcase)  || f["custom_field_name"].try(:downcase)  == custom_field_identifier.try(:downcase)
          end

          options[:field] = custom_field_identifier
          
          if parent_chunk_object[:placeholder]
            custom_field_item["identifier"] = ""
            custom_field_item["content"] = ""
          end

          if custom_field_item.present?
            render_chunk_content(
              custom_field_item["identifier"],
              custom_field_item["content"],
              custom_field_item["chunk_type"],
              { parent_identifier: chunk_identifier, custom_field_identifier:  custom_field_identifier}.merge(options)
            )
          end
        rescue => errors
          puts errors
          content_tag(:span, "&nbsp".html_safe) 
        end
      end

      def render_chunk_content(chunk_identifier, chunk_content, chunk_type,options = {})

        begin 
          # Always sanitize the content!!
          chunk_content = ActionController::Base.helpers.sanitize(chunk_content) unless chunk_type == 'rich_text'
          chunk_content = variable_parse!(chunk_content, options[:variable_fallbacks], options[:variable_values])

          css_class = options[:class]

          if chunk_type == "image"
            display_type = "image"
          else 
            display_type = options[:display_type] || "span"
          end

          chunk_data = { :chunk => chunk_identifier, :chunk_editable => false, :chunk_type => chunk_type }

          chunk_data.merge!({parent_identifier: options[:parent_identifier]}) if options[:parent_identifier].present?
          chunk_data.merge!({custom_field_identifier: options[:custom_field_identifier]}) if options[:custom_field_identifier].present?

          case display_type
          when "span"
            if chunk_type == "rich_text"
              content = content_tag("em-span", :class => "editmode-richtext-editor #{css_class}", :data => chunk_data.merge!({:chunk_editable => true}) ) do
                chunk_content.html_safe
              end
            else
              content_tag("em-span", :class => css_class, :data => chunk_data.merge!({:chunk_editable => true}) ) do
                chunk_content
              end
            end
          when "image"
            chunk_content = chunk_content.blank? || chunk_content == "/images/original/missing.png" ? 'http://lvh.me:3001/upload.png' : chunk_content
            image_tag(chunk_content, :data => chunk_data, :class => css_class) 
          end
        rescue => errors
          puts errors
          content_tag("em-span", "&nbsp".html_safe) 
        end

      end

      def chunk_display(label, identifier, options = {}, &block)
        branch_id = params[:em_branch_id]
        # This method should never show an error. 
        # If anything goes wrong fetching content
        # We should just show blank content, not
        # prevent the page from loading.
        begin
          branch_params = branch_id.present? ? "branch_id=#{branch_id}" : ""
          field = options[:field].presence || ""          
          cache_identifier = "chunk_#{identifier}#{branch_id}#{field}"
          url = "#{api_root_url}/chunks/#{identifier}?project_id=#{Editmode.project_id}&#{branch_params}"
          cached_content_present = Rails.cache.exist?(cache_identifier)
          
          if !cached_content_present
            response = HTTParty.get(url)
            response_received = true if response.code == 200
          end

          if !cached_content_present && !response_received
            raise "No response received"
          else
            if field.present? && response.present?
              field_content = response["content"].detect {|f| f["custom_field_identifier"].downcase == field.downcase || f["custom_field_name"].downcase == field.downcase }
              if field_content
                content = field_content["content"]
                type = field_content["chunk_type"]
                identifier = field_content["identifier"]
              end
            end

            variable_fallbacks = Rails.cache.fetch("#{cache_identifier}_variables") do
              response['variable_fallbacks'].presence || {}
            end

            chunk_content = Rails.cache.fetch(cache_identifier) do  
              content.presence || response["content"]
            end

            chunk_type = Rails.cache.fetch("#{cache_identifier}_type") do  
              type.presence || response['chunk_type']
            end

            options[:variable_fallbacks] = variable_fallbacks
            options[:variable_values] = options[:variables]
            
            render_chunk_content(identifier,chunk_content,chunk_type, options)

          end

        rescue => error
          # Show fallback content by default
          return content_tag("em-span", &block) if block_given?
          # Otherwise show a span with no content to 
          # maintain layout
          content_tag("em-span", "&nbsp".html_safe) 
        end
      end
      alias_method :chunk, :chunk_display


      def render_custom_field(field_name, options={})
        options[:variable_fallbacks] = @custom_field_chunk["variable_fallbacks"] || {}
        options[:variable_values] = options[:variables] || {}
        
        chunk_field_value(@custom_field_chunk, field_name, options)
      end
      alias_method :F, :render_custom_field

      def render_chunk(identifier, *args, &block)
        field, options = parse_arguments(args)
        options[:field] = field
        chunk_display('label', identifier, options, &block)
      end
      alias_method :E, :render_chunk


      def variable_parse!(content, variables = {}, values = {})
        tokens = content.scan(/\{{(.*?)\}}/)
        if tokens.any?
          tokens.flatten! 
          tokens.each do |token|
            token_value = values[token.to_sym] || variables[token] || ""
            sanitized_value = ActionController::Base.helpers.sanitize(token_value)

            content.gsub!("{{#{token}}}", sanitized_value)
          end
        end

        content
      end

      def no_response_received(id = "")
        "Sorry, we can't find a chunk using this identifier: \"#{id}\". This can happen if you've deleted a chunk on editmode.com or if your local cache is out of date. If it persists, try running Rails.cache clear."
      end
      
      def require_field_id
        "Field ID or Field Name is required to retrieve a collection item"
      end
    end
  end
end
