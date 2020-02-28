Rails.application.routes.draw do
  # Use a namespaced url because /:generic can easily be overwritten by app default routes
  get "/editmode/clear_cache" => "editmode#clear_cache" , :as => :editmode_clear_cache
  # Support older route structure. To be expired
  get "/chunksapp/clear_cache" => "editmode#clear_cache" , :as => :chunksapp_clear_cache
end