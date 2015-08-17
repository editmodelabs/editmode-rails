module Chunks

  module ScriptTagHelper

    def chunks_script_tag()
      str = <<-CHUNKS_SCRIPT
      <script src="https://chunksapp.com/assets/chunks.js"></script>
      CHUNKS_SCRIPT

      str.respond_to?(:html_safe) ? str.html_safe : str
    end
    
  end

end