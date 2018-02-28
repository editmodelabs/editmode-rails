module ChunksRails
  class Railtie < Rails::Railtie
    initializer "chunks-rails" do |app|

      ActiveSupport.on_load :action_view do
        include ChunksRails::ActionViewExtensions::ChunksHelper
      end
      ActiveSupport.on_load :action_controller do
        include AutoInclude::Method

        if respond_to? :after_action
          after_action :chunks_auto_include
        else
          after_filter :chunks_auto_include
        end
      end
    end
  end
end