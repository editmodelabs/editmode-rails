module EditModeRails

  module AutoInclude

    module Method
      def editmode_auto_include
        EditModeRails::AutoInclude::Filter.filter(self)
      end
    end

    class Filter

      CLOSING_BODY_TAG = %r{</body>}
      def self.filter(controller)
        auto_include_filter = new(controller)
        return unless auto_include_filter.include_javascript?

        auto_include_filter.include_javascript!
      end

      attr_reader :controller

      def initialize(kontroller)
        @controller = kontroller
      end

      def include_javascript!
        response.body = response.body.gsub(CLOSING_BODY_TAG, editmode_script_tag.output + '\\0')
      end

      def include_javascript?
        enabled_for_environment? &&
        html_content_type? &&
        response_has_closing_body_tag? &&
        editmode_script_tag.valid?
      end

      private
      def response
        controller.response
      end

      def html_content_type?
        response.content_type == 'text/html'
      end

      def response_has_closing_body_tag?
        !!(response.body[CLOSING_BODY_TAG])
      end

      def editmode_script_tag
        @script_tag ||= EditModeRails::ScriptTag.new()
      end

      def enabled_for_environment?
        enabled_environments = ["production","development","staging"]
        return true if enabled_environments.nil?
        enabled_environments.map(&:to_s).include?(Rails.env)
      end

    end

  end

end