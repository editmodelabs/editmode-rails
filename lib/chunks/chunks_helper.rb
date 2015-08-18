module Chunks

  module ChunksHelper
   
    def chunk_display(label,identifier,options={})

      display_type = options[:display_type] || "span"

      chunk_content = Rails.cache.fetch("chunk_#{identifier}") do  
        url = "http://www.chunksapp.com/chunks/#{identifier}"
        response = HTTParty.get(url)
        chunk_content = response['content']
      end
      
      css_class = options[:css_class]

      if chunk_content.include? "\n"
        chunk_content = GitHub::Markdown.render_gfm( chunk_content ).html_safe
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