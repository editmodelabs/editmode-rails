module ChunksRails

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
      
      str = <<-CHUNKS_SCRIPT
  <script src="#{script_url}" async ></script>
      CHUNKS_SCRIPT

      str.respond_to?(:html_safe) ? str.html_safe : str

    end

    def script_url 
      ENV["CHUNKS_OVERRIDE_SCRIPT_URL"] || "https://www.chunksapp.com/assets/chunks.js"
    end

  end

end