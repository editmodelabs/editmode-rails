module EditModeRails

  class ScriptTag

    def self.generate(*args)
      new(*args).output
    end

    def initialize(options = {})
      
    end

    def valid?
      true
    end

    def output
      
      str = <<-EDITMODE_SCRIPT
  <script src="#{script_url}" async ></script>
      EDITMODE_SCRIPT

      str.respond_to?(:html_safe) ? str.html_safe : str

    end

    def script_url 
      ENV["EDITMODE_OVERRIDE_SCRIPT_URL"] || "https://static.editmode.com/js/editmode-original.js"
    end

  end

end