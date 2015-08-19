Rails.application.routes.prepend do
	get "/chunks_expire_cache" => "chunksapp#clear_cache" , :as => :chunks_clear_cache
end