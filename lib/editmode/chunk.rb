class Editmode::Chunk
  def initialize
  end

  class << self
    def retrieve(project_id = Editmode.project_id, options = {})
      begin
        root_url = Editmode.api_root_url
        chunk_id = options[:identifier] || options[:content_key]

        url = "#{root_url}/chunks/#{chunk_id}?project_id=#{project_id}"
        response = HTTParty.get(url)

        if chunk_id.present?
          return response
        else
          chunks = response.try(:[], "chunks")
          chunks ||= []
        end
      rescue => er
        Rails.logger.info er
        []
      end
    end
  end
end