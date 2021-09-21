module Editmode

  class ScriptTag

    def self.generate(*args)
      new(*args).output
    end

    def initialize(options = {})
      
    end

    def valid?
      true
    end

    def has_watermark
      has_watermark = Rails.cache.fetch('chunks_project_has_watermark', expires_in: 1.hour,) do
        project = HTTParty.get(Editmode.api_root_url + "/projects/#{Editmode.project_id}")
        project["has_watermark"]
      end
    end

    def watermark_tag
      if has_watermark 
        '<div style="z-index: 9999; bottom: 8px; right: 8px; position: fixed; opacity: 1; display: flex; align-items: center; background: rgba(255, 255, 255, 0.9); cursor: pointer; border-radius: 5px; padding: 2px 5px 2px 2px; box-shadow: rgba(0, 0, 0, 0.1) 0px 1px 3px 0px, rgba(0, 0, 0, 0.06) 0px 1px 2px 0px;"><svg preserveAspectRatio="xMidYMid meet" version="1.0" viewBox="0 0 22 23" xmlns="http://www.w3.org/2000/svg" width="24" height="24" style="margin-right: 5px">
          <g opacity=".8">
          <path d="m1.6925 4.2131s6.9175-3.7666 7.5952-4.1192c0.67776-0.35253 1.2739 0.35253 1.2739 1.025v8.0945c0 1.7257-0.2199 1.7257-0.92232 2.1684-0.70239 0.4428-7.9929 4.3926-8.3935 4.5953-0.40061 0.2028-1.2459-0.0997-1.2459-1.0136v-8.4086c0-1.5545 1.6925-2.3418 1.6925-2.3418z" clip-rule="evenodd" fill="#203260" fill-rule="evenodd"></path>
          <mask id="b" x="0" y="0" width="11" height="17" mask-type="alpha" maskUnits="userSpaceOnUse">
          <path d="m1.6925 4.2131s6.9175-3.7666 7.5952-4.1192c0.67776-0.35253 1.2739 0.35253 1.2739 1.025v8.0945c0 1.7257-0.2199 1.7257-0.92232 2.1684-0.70239 0.4428-7.9929 4.3926-8.3935 4.5953-0.40061 0.2028-1.2459-0.0997-1.2459-1.0136v-8.4086c0-1.5545 1.6925-2.3418 1.6925-2.3418z" clip-rule="evenodd" fill="#fff" fill-rule="evenodd"></path>
          </mask>
          <g mask="url(#b)">
          <path d="m2.9346 7.9074s6.9175-3.7666 7.5952-4.1192c0.6778-0.35254 1.2739 0.35253 1.2739 1.025v8.0944c0 1.7258-0.2199 1.7258-0.9223 2.1685s-7.9929 4.3925-8.3935 4.5953-1.2458-0.0997-1.2458-1.0136v-8.4087c0-1.5545 1.6925-2.3418 1.6925-2.3418z" clip-rule="evenodd" fill="#000719" fill-rule="evenodd"></path>
          </g>
          <path d="m6.978 7.3208s6.9175-3.7666 7.5952-4.1192c0.6778-0.35254 1.2739 0.35253 1.2739 1.025v8.0945c0 1.7257-0.2199 1.7257-0.9223 2.1684-0.7023 0.4428-7.9929 4.3926-8.3935 4.5954-0.40061 0.2027-1.2459-0.0998-1.2459-1.0137v-8.4086c0-1.5545 1.6925-2.3418 1.6925-2.3418z" clip-rule="evenodd" fill="#223464" fill-rule="evenodd"></path>
          <mask id="a" x="5" y="3" width="11" height="17" mask-type="alpha" maskUnits="userSpaceOnUse">
          <path d="m6.978 7.3208s6.9175-3.7666 7.5952-4.1192c0.6778-0.35254 1.2739 0.35253 1.2739 1.025v8.0945c0 1.7257-0.2199 1.7257-0.9223 2.1684-0.7023 0.4428-7.9929 4.3926-8.3935 4.5954-0.40061 0.2027-1.2459-0.0998-1.2459-1.0137v-8.4086c0-1.5545 1.6925-2.3418 1.6925-2.3418z" clip-rule="evenodd" fill="#fff" fill-rule="evenodd"></path>
          </mask>
          <g mask="url(#a)">
          <path d="m8.4483 11.062s6.9175-3.7667 7.5952-4.1192c0.6778-0.35253 1.2739 0.35254 1.2739 1.025v8.0945c0 1.7257-0.2199 1.7257-0.9222 2.1684-0.7024 0.4428-7.993 4.3926-8.3936 4.5954-0.40061 0.2027-1.2458-0.0998-1.2458-1.0136v-8.4087c0-1.5546 1.6925-2.3418 1.6925-2.3418z" clip-rule="evenodd" fill="#000719" fill-rule="evenodd"></path>
          </g>
          <path d="m12.543 10.883s6.9235-3.7101 7.6019-4.0573c0.6783-0.34725 1.275 0.34724 1.275 1.0096v7.9731c0 1.6998-0.2201 1.6998-0.9231 2.1359s-7.9999 4.3267-8.4009 4.5264c-0.4009 0.1997-1.2469-0.0983-1.2469-0.9984v-8.2826c0-1.5312 1.694-2.3067 1.694-2.3067z" clip-rule="evenodd" fill="#405489" fill-rule="evenodd"></path>
          </g>
        </svg><span style="font-size: 13px; font-weight: 600;">Powered by Editmode</span></div>'
      else 
        ""
      end
    end

    def output
      str = <<-EDITMODE_SCRIPT
  #{watermark_tag}
  <script>window.chunksProjectLoaded = true</script>
  <script>window.chunksProjectIdentifier = '#{Editmode.project_id}'</script>
  <script>window.editmodeENV = '#{ENV["EDITMODE_ENV"] || 'production'}'</script>
  <script src="#{script_url}" async ></script>
      EDITMODE_SCRIPT

      str.respond_to?(:html_safe) ? str.html_safe : str

    end

    def script_url 
      ENV["EDITMODE_OVERRIDE_SCRIPT_URL"] || "https://unpkg.com/editmode-magic-editor@~1/dist/magic-editor.js"
    end

  end

end