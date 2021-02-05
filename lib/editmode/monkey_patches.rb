require 'httparty'

# Support logging on httparty requests
module HTTParty
  class Request
    alias_method :_original_perform, :perform
    def perform(&block)
      payload = {
        method: http_method.const_get(:METHOD),
        url: uri
      }
      ActiveSupport::Notifications.instrument 'request.httparty', payload do
        _original_perform(&block)
      end
    end
  end
end