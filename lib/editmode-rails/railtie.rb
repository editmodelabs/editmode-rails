module EditModeRails
  class Railtie < Rails::Railtie
    initializer "editmode-rails" do |app|

      ActiveSupport.on_load :action_view do
        include EditModeRails::ActionViewExtensions::EditModeHelper
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