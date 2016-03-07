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
  <script src="https://www.chunksapp.com/assets/chunks.js" async ></script>
      CHUNKS_SCRIPT

      str.respond_to?(:html_safe) ? str.html_safe : str

    end

  end

end