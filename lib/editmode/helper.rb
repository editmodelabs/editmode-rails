module Editmode
  module Helper
    # Render non-editable content
    def e(identifier, *args)
      field, options = parse_arguments(args)
      begin
        chunk = Editmode::ChunkValue.new(identifier, **options.merge({raw: true}))
        
        if chunk.chunk_type == 'collection_item'
          chunk.field(field)
        else
          chunk.content
        end 
      rescue => er
        Rails.logger.info "#{er}: We can't render content for #{identifier}"
        return ""
      end
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