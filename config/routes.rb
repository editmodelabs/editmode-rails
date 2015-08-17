Rails.application.routes.draw do
  get "chunks_clear_cache" => "chunks#clear_cache" , :as => :chunks_clear_cache
end