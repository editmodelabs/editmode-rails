module IntercomRails
  class Railtie < Rails::Railtie
    initializer "chunks" do |app|
      ActionView::Base.send :include, ScriptTagHelper
      ActionController::Base.send :include, AutoInclude::Method
      ActionController::Base.after_filter :chunks_auto_include
    end

    rake_tasks do
      load 'intercom-rails/intercom.rake'
    end
  end
end