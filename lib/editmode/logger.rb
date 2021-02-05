require 'active_support'

module Editmode
  class Logger
    attr_accessor :httparty_subscription

    def log_level=(level)
      if level == :normal
        # Add more subscription here
        enable_httparty!
      end
    end

    def enable_httparty!
      @httparty_subscription = ActiveSupport::Notifications.subscribe('request.httparty') do |name, start, ending, transaction_id, payload|
        event = ActiveSupport::Notifications::Event.new(name, start, ending, transaction_id, payload)
        Rails.logger.info "  HTTParty -- " + "#{event.payload[:method]} #{event.payload[:url]} (Duration: #{event.duration}ms)"
        Thread.current[:http_runtime] ||= 0
        Thread.current[:http_runtime] += event.duration
        payload[:http_runtime] = event.duration
      end
    end

    def unsubscribe(subscriber)
      ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber.present?
    end
  end
end