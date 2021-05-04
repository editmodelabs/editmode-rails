require 'editmode/helper'
require 'action_view'
require 'httparty'

module Editmode
  module ActionViewExtensions
    module EditmodeHelper
      include ::ActionView::Helpers::TagHelper
      include ::ActionView::Helpers::TextHelper
      include ::ActionView::Helpers::AssetTagHelper
      include ::ActionView::Context
      include Editmode::Helper


      def api_version
        # Todo Add Header Version
      end

      def allowed_tag_attributes
        [:style, :href, :title, :src, :alt, :width, :height]
      end

      def api_root_url
        ENV["EDITMODE_OVERRIDE_API_URL"] || "https://api.editmode.com"
      end

      def chunk_collection(collection_identifier, **options, &block)
        branch_params = params[:em_branch_id].present? ? "branch_id=#{params[:em_branch_id]}" : ""
        branch_id = params[:em_branch_id].presence
        tags = options[:tags].presence || []
        limit = options[:limit].presence

        parent_class = options[:class] || ""
        item_class = options[:item_class] || ""
        
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
              content_tag :div, class: "chunks-collection-wrapper #{parent_class}", data: {chunk_collection_identifier: collection_identifier} do
                chunks.each_with_index do |chunk, index|
                  @custom_field_chunk = chunk
                  if options[:without_item_wrapper].present?
                    yield(@custom_field_chunk, index)
                  else
                    concat(content_tag(:div, class: "chunks-collection-item--wrapper #{item_class}") do
                      yield(@custom_field_chunk, index)
                    end)
                  end
                end

                # Placeholder element for new collection item
                @custom_field_chunk = chunks.first.merge!({placeholder: true})
                concat(content_tag(:div, class: "chunks-hide chunks-col-placeholder-wrapper") do
                  yield(@custom_field_chunk)
                end)
              end 
            else
              content_tag(:span, "&nbsp".html_safe)
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
          chunk_value = Editmode::ChunkValue.new(parent_chunk_object["identifier"], options.merge({response: parent_chunk_object}))
          custom_field_item = chunk_value.field_chunk(custom_field_identifier)

          options[:field] = custom_field_identifier
          
          if parent_chunk_object[:placeholder]
            custom_field_item["identifier"] = ""
            custom_field_item["content"] = ""
          end

          if custom_field_item.present?
            render_chunk_content(
              custom_field_item["identifier"],
              chunk_value.field(custom_field_identifier),
              custom_field_item["chunk_type"],
              { parent_identifier: chunk_identifier, custom_field_identifier:  custom_field_identifier}.merge(options)
            )
          end
        rescue => errors
          puts errors
          content_tag(:span, "&nbsp".html_safe) 
        end
      end

      def render_chunk_content(chunk_identifier, chunk_content, chunk_type, options = {})
        begin 
          css_class = options[:class]
          cache_id = options[:cache_identifier]

          if chunk_type == "image"
            display_type = "image"
          else 
            display_type = options[:display_type] || "span"
          end

          chunk_data = { :chunk => chunk_identifier, :chunk_editable => false, :chunk_type => chunk_type }

          chunk_data.merge!({parent_identifier: options[:parent_identifier]}) if options[:parent_identifier].present?
          chunk_data.merge!({custom_field_identifier: options[:custom_field_identifier]}) if options[:custom_field_identifier].present?
          chunk_data.merge!({chunk_cache_id: cache_id}) if cache_id.present?
          chunk_data.merge!({chunk_collection_identifier: options[:collection_id]}) if options[:collection_id].present?
          chunk_data.merge!({chunk_content_key: options[:content_key]}) if options[:content_key].present?

          case display_type
          when "span"
            if chunk_type == "rich_text"
              content = content_tag("em-span", :class => "editmode-richtext-editor #{css_class}", :data => chunk_data.merge!({:chunk_editable => true}), **options.slice(*allowed_tag_attributes) ) do
                chunk_content.html_safe
              end
            else
              content_tag("em-span", :class => css_class, :data => chunk_data.merge!({:chunk_editable => true}), **options.slice(*allowed_tag_attributes) ) do
                chunk_content.html_safe
              end
            end
          when "image"
            chunk_content = chunk_content.blank? || chunk_content == "/images/original/missing.png" ? 'https://www.editmode.com/upload.png' : chunk_content
            image_tag(chunk_content, :data => chunk_data, :class => css_class, **options.slice(*allowed_tag_attributes)) 
          end
        rescue => errors
          puts errors
          content_tag("em-span", "&nbsp".html_safe) 
        end

      end

      def chunk_display(label, identifier, options = {}, &block)
        options[:branch_id] = params[:em_branch_id] if params[:em_branch_id].present?
        # This method should never show an error. 
        # If anything goes wrong fetching content
        # We should just show blank content, not
        # prevent the page from loading.
        begin
          field = options[:field].presence || ""          
          options[:referrer] = request.present? && request.url || ""
          chunk_value = Editmode::ChunkValue.new(identifier, options)
          
          if field.present? && chunk_value.chunk_type == 'collection_item'
            chunk_content = chunk_value.field(field)
            identifier = chunk_value.field_chunk(field)["identifier"]
            chunk_type = chunk_value.field_chunk(field)["chunk_type"]
            options[:collection_id] = chunk_value.collection_id
          else
            chunk_content = chunk_value.content
            chunk_type = chunk_value.chunk_type
            identifier = chunk_value.response["identifier"] unless identifier.include? "cnk_"
          end

          options[:cache_identifier] = chunk_value.identifier
          options[:content_key] = chunk_value.response.try(:[], "content_key")
          render_chunk_content(identifier, chunk_content, chunk_type, options)

        rescue => error
          puts error
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

      def no_response_received(id = "")
        "Sorry, we can't find a chunk using this identifier: \"#{id}\". This can happen if you've deleted a chunk on editmode.com or if your local cache is out of date. If it persists, try running Rails.cache clear."
      end
      
      def require_field_id
        "Field ID or Field Name is required to retrieve a collection item"
      end
    end
  end
end
