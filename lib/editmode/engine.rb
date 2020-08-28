require 'editmode/chunk_value'

module Editmode
  class Engine < Rails::Engine
    ActionController::Base.class_eval do
      def e(identifier, options = {})
        begin
          chunk = Editmode::ChunkValue.new(identifier, **options)
          if chunk.chunk_type == 'collection_item'
            chunk.field(options[:field])
          else
            chunk.content
          end 
        rescue => er
          raise er
        end
      end
    end
  end
end