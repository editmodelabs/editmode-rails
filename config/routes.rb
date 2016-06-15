Rails.application.routes.draw do
	# Use a namespaced url because /:generic can easily be overwritten by app default routes
	get "/chunksapp/clear_cache" => "chunksapp#clear_cache" , :as => :chunks_clear_cache
end