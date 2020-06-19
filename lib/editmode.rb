require "active_support/dependencies"
require "editmode-rails/version"
require 'editmode-rails/script_tag'
require 'editmode-rails/action_view_extensions/editmode_helper'
require 'editmode-rails/auto_include_filter'
require 'editmode-rails/railtie' if defined? Rails
require 'editmode-rails/engine' if defined?(Rails)

class Editmode
  class << self
    include ::EditModeRails::ActionViewExtensions::EditModeHelper
    def project_id
      @config.project_id
    end

    def access_token
      @config.access_token
    end

    def config
      # Todo: Instantiate in editmode initializer or base controllers
      # Todo: Add a generator to create initializer an file? 
      @config ||= Configuration.new
    end

    def setup
      yield config
    end

    def chunk_value(identifier, **options)
      body = options[:values].presence || {}
      field_id = options[:field_id].presence
      branch_id = options[:branch_id].presence

      branch_params = branch_id.present? ? "branch_id=#{branch_id}" : ""
      cache_identifier = "chunk_#{identifier}#{branch_id}"
      url = "#{api_root_url}/chunks/#{identifier}?#{branch_params}"

      begin
        response = HTTParty.get(url, query: body)
        response_received = true if response.code == 200

        if !response_received
          raise "No response received"
        else
          if field_id.present?
            chunk = response["content"].detect {|f| f["custom_field_identifier"] == field_id }
            chunk['content']
          else
            response['content']
          end
        end
      rescue => error
        # Todo: Send a log to editmode prob like sentry
        return "No response received"
      end
    end
  end

  class Configuration
    attr_accessor :project_id, :access_token
  end
end