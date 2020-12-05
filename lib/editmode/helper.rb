module Editmode
  module Helper
    # Render non-editable content
    def e(identifier, *args)
      field, options = parse_arguments(args)
      begin
        chunk = Editmode::ChunkValue.new(identifier, options.merge({raw: true}))
        render_noneditable_chunk(chunk, field, options)
      rescue => er
        puts er
      end
    end

    def render_noneditable_chunk(chunk, field=nil, options=nil)
      return render_collection_item(chunk, field, options) if chunk.chunk_type == 'collection_item'

      render_content(chunk, options)
    end

    def render_collection_item(chunk, field=nil, options=nil)
      return render_image(chunk.field(field), options[:class]) if chunk.field_chunk(field)['chunk_type'] == 'image'

      chunk.field(field)
    end

    def render_content(chunk, options=nil)
      return render_image(chunk.content, options[:class]) if chunk.chunk_type == 'image'

      chunk.content
    end

    def render_image(content, css_class=nil)
      image_tag(content, class: css_class)
    end

    def render_custom_field_raw(label, options={})
      e(@custom_field_chunk["identifier"], label, options.merge({response: @custom_field_chunk}))
    end
    alias_method :f, :render_custom_field_raw

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
