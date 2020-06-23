require "active_support/dependencies"
require "editmode/version"
require 'editmode/script_tag'
require 'editmode/action_view_extensions/editmode_helper'
require 'editmode/auto_include_filter'
require 'editmode/railtie' if defined? Rails
require 'editmode/engine' if defined?(Rails)

module Editmode
  class << self
    include Editmode::ActionViewExtensions::EditmodeHelper
    def project_id=(id)
      config.project_id = id
    end

    def project_id
      config.project_id
    end

    def access_token
      config.access_token
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
      
      begin
        branch_params = branch_id.present? ? "branch_id=#{branch_id}" : ""
        url = "#{api_root_url}/chunks/#{identifier}?#{branch_params}"

        cache_identifier = "chunk_value_#{identifier}#{field_id}#{branch_id}"
        cached_content_present = Rails.cache.exist?(cache_identifier)

        if !cached_content_present
          response = HTTParty.get(url, query: body)
          response_received = true if response.code == 200
        end

        if !cached_content_present && !response_received
          raise "No response received"
        else
          chunk = Rails.cache.fetch(cache_identifier) do
            response['content']
          end

          if field_id.present?
            chunk = chunk.detect {|f| f["custom_field_identifier"] == field_id }
            chunk = chunk['content']
          end
          
          chunk          
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