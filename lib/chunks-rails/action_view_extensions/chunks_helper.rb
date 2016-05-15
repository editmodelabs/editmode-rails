
module ChunksRails

  module ActionViewExtensions
    module ChunksHelper

      def api_version
        "v1"
      end

      def api_root_url
        ENV["CHUNKS_OVERRIDE_API_URL"] || "https://www.chunksapp.com/api"
      end

      def versioned_api_url
        "#{api_root_url}/#{api_version}"
      end
     
      def chunk_display(label,identifier,options={})

        display_type = options[:display_type] || "span"

        chunk_content = Rails.cache.fetch("chunk_#{identifier}") do  
          url = "#{versioned_api_url}/chunks/#{identifier}"
          response = HTTParty.get(url)
          chunk_content = response['content']
        end
        
        css_class = options[:css_class]

        if chunk_content.include? "\n"
          renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
          markdown = Redcarpet::Markdown.new(renderer, extensions = {})
          chunk_content = markdown.render(chunk_content).html_safe
        end

        case display_type
        when "span"
          content_tag(:span, :class => css_class, :data => {:chunk => identifier}) do
            chunk_content
          end
        when "raw"
          chunk_content
        end

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