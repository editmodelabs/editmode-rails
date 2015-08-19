require "active_support/dependencies"

require "chunks-rails/version"
require 'chunks-rails/script_tag'
require 'chunks-rails/action_view_extensions/chunks_helper'
require 'chunks-rails/auto_include_filter'
require 'chunks-rails/railtie' if defined? Rails

module ChunksRails
  # Your code goes here...
end

require 'chunks-rails/engine' if defined?(Rails)