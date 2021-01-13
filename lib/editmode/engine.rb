require 'rails/engine'
require 'action_controller'
require 'editmode/helper'

module Editmode
  class Engine < Rails::Engine
    ActionController::Base.class_eval do
      include Editmode::Helper
    end
  end
end