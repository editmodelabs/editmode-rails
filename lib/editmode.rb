require "active_support/dependencies"

require "editmode-rails/version"

require 'editmode-rails/script_tag'
require 'editmode-rails/action_view_extensions/editmode_helper'
require 'editmode-rails/auto_include_filter'
require 'editmode-rails/railtie' if defined? Rails

module EditModeRails
  # Your code goes here...
end

require 'editmode-rails/engine' if defined?(Rails)