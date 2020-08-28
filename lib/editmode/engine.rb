require 'editmode/chunk_value'

module Editmode
  class Engine < Rails::Engine
    ActionController::Base.class_eval do
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

      private

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
end