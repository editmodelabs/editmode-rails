module Chunks

  class ScriptTag

    def self.generate(*args)
      new(*args).output
    end

    def valid?
      true
    end

    def output
      
      str = <<-CHUNKS_SCRIPT
      <script src="https://chunksapp.com/assets/chunks.js"></script>
      CHUNKS_SCRIPT

      str.respond_to?(:html_safe) ? str.html_safe : str

    end

end