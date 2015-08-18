module Chunks
  class Railtie < Rails::Railtie
    initializer "chunks" do |app|
      ActionView::Base.send :include, Chunks::ActionViewExtensions::ChunksHelper
      ActionController::Base.send :include, AutoInclude::Method
      ActionController::Base.after_filter :chunks_auto_include
    end
  end
end