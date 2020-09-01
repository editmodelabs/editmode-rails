require 'editmode/chunk_value'
require 'editmode/helper'

module Editmode
  class Engine < Rails::Engine
    ActionController::Base.class_eval do
      include Editmode::Helper
    end
  end
end