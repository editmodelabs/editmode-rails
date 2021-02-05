require "active_support/dependencies"
require "editmode/version"
require 'editmode/script_tag'
require 'editmode/action_view_extensions/editmode_helper'
require 'editmode/auto_include_filter'
require 'editmode/chunk_value'
require 'editmode/railtie' if defined? Rails
require 'editmode/engine' if defined?(Rails)
require 'editmode/monkey_patches'
require 'editmode/logger'
module Editmode
  class << self
    include Editmode::ActionViewExtensions::EditmodeHelper
    include Editmode::Helper

    def project_id=(id)
      config.project_id = id
    end

    def project_id
      config.project_id
    end

    def logger
      config.logger
    end

    def log_level
      config.log_level
    end

    def log_level=(level)
      config.log_level = level
    end

    def access_token
      config.access_token
    end

    def config
      @config ||= Configuration.new
    end

    def setup
      yield config
    end

    def chunk_value(identifier, **options)
      begin
        Editmode::ChunkValue.new(identifier, **options )
      rescue => er
        puts er
      end
    end
  end

  class Configuration
    attr_accessor :access_token, :variable
    attr_reader :project_id, :log_level

    def logger
      @logger ||= Editmode::Logger.new
    end

    def project_id=(id)
      @project_id = id
    end

    def log_level=(level)
      @log_level = level
      logger.log_level = level
    end
  end
end