module Editmode
  module Helper
    # Render non-editable content
    def e(identifier, *args)
      field, options = parse_arguments(args)
      begin
        chunk = Editmode::ChunkValue.new(identifier, options)
        if chunk.chunk_type == 'collection_item'
          chunk.field(field)
        else
          chunk.content
        end 
      rescue => er
        raise er
      end
    end

    def render_custom_field_raw(label, options={})
      options.merge!(raw: true)
      chunk_field_value(@custom_field_chunk, label, options)
    end
    alias_method :f, :render_custom_field_raw

    def chunk_field_value(parent_chunk_object, custom_field_identifier, options = {})
      begin 
        chunk_identifier = parent_chunk_object["identifier"]
        custom_field_item = parent_chunk_object["content"].detect {|f| f["custom_field_identifier"] == custom_field_identifier || f["custom_field_name"] == custom_field_identifier }
        
        if options[:raw]
          return custom_field_item["content"]
        end

        if custom_field_item.present?
          render_chunk_content(
            custom_field_item["identifier"],
            custom_field_item["content"],
            custom_field_item["chunk_type"],
            { parent_identifier: chunk_identifier }.merge(options)
          )
        end
      rescue => errors
        puts errors
        content_tag(:span, "&nbsp".html_safe) 
      end
    end

    def parse_arguments(args)
      field = nil
      options = {}
      if args[0].class.name == 'String'
        field = args[0]
        options =  args[1] || {}
      elsif args[0].class.name == 'Hash'
        options =  args[0] || {}
      end
      return field, options
    end
  end
end