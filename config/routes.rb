Rails.application.routes.draw do
  # Use a namespaced url because /:generic can easily be overwritten by app default routes
  get "/editmode/clear_cache" => "editmode#clear_cache" , :as => :editmode_clear_cache
end