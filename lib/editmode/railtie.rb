require 'rails/railtie'
module Editmode
  class Railtie < Rails::Railtie
    initializer "editmode" do |app|

      ActiveSupport.on_load :action_view do
        include Editmode::ActionViewExtensions::EditmodeHelper
      end
      ActiveSupport.on_load :action_controller do
        include AutoInclude::Method

        if respond_to? :after_action
          after_action :editmode_auto_include
        else
          after_filter :editmode_auto_include
        end
      end
    end
  end
end