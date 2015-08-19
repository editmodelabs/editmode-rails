module ChunksRails
  class Railtie < Rails::Railtie
    initializer "chunks-rails" do |app|
      ActionView::Base.send :include, ChunksRails::ActionViewExtensions::ChunksHelper
      ActionController::Base.send :include, AutoInclude::Method
      ActionController::Base.after_filter :chunks_auto_include
    end
  end
end