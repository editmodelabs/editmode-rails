module EditModeRails

  module ActionViewExtensions
    module EditModeHelper

      require 'httparty'

      def api_version
        "v1"
      end

      def api_root_url
        ENV["EDITMODE_OVERRIDE_API_URL"] || "https://www.editmode.app/api"
      end

      def versioned_api_url
        "#{api_root_url}/#{api_version}"
      end
     
      def chunk_collection(collection_identifier,has_tags=[])
        begin 
          url = "#{versioned_api_url}/chunks?collection_identifier=#{collection_identifier}"
          response = HTTParty.get(url)
          chunks = response["chunks"]
          return chunks
        rescue => error
          puts error 
          []
        end
      end

      def chunk_property(chunk_info,custom_field_identifier=nil,options={})

        chunk_identifier = chunk_info["identifier"]

        if custom_field_identifier
          custom_field_info = chunk_info["custom_fields"].select{|custom_field| custom_field["custom_field_identifier"] == custom_field_identifier }[0]
          if custom_field_info.present? 
            chunk_display("",chunk_identifier,options,custom_field_info)
          end
        else 
          chunk_display("",chunk_identifier,options)
        end
      end

      def chunk_display(label,identifier,options={},custom_field_info={})
        
        begin 
          if custom_field_info.present?
            chunk_content = custom_field_info["value"]
          else
            chunk_content = Rails.cache.fetch("bit_#{identifier}") do  
              url = "#{versioned_api_url}/bits/#{identifier}"
              response = HTTParty.get(url)
              chunk_content = response['content']
            end
          end

          display_type = options[:display_type] || "span"
          css_class = options[:css_class]
          content_type = "plain"

          # Simple check to see if returned chunk contains html. Regex will need to be improved
          if /<[a-z][\s\S]*>/i.match(chunk_content)
            content_type = "rich"
            chunk_content = sanitize chunk_content.html_safe
          elsif chunk_content.include? "\n"
            content_type = "rich"
            renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
            markdown = Redcarpet::Markdown.new(renderer, extensions = {})
            chunk_content = markdown.render(chunk_content).html_safe
          end

          additional_data_properties = custom_field_info.present? ? { :custom_field_identifier => custom_field_info["custom_field_identifier"] } : {}

          case display_type
          when "span"
            if content_type == "rich"
              content_tag(:span, :class => css_class, :data => {:chunk => identifier, :chunk_editable => false}.merge(additional_data_properties) ) do
                chunk_content
              end
            else
              content_tag(:span, :class => css_class, :data => {:chunk => identifier, :chunk_editable => true}.merge(additional_data_properties)) do
                chunk_content
              end
            end
          when "raw"
            chunk_content
          end
       rescue => error
        puts error
       end

      end

      def bit(label,identifier,options={})
        chunk_display(label,identifier)
      end

      def chunk(label,identifier,options={})
        chunk_display(label,identifier)
      end

      def raw_chunk(label,identifier,options={})
        chunk_display(label,identifier,options.merge(:display_type => "raw"))
      end
      
    end
  end

end
