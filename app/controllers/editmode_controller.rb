class EditmodeController < ApplicationController

  def clear_cache
    if params[:full]
      Rails.cache.clear
      render status: 200, json: {:response => "success"}
    elsif params[:collection]
      cache_id = "collection_#{params[:identifier]}"
      Rails.cache.delete_matched("#{cache_id}*")
      render status: 200, json: {:response => "success"}
    elsif params[:variable_cache_project_id]
      project_id = params[:variable_cache_project_id]
      Rails.cache.delete("chunk_#{project_id}_variables")
      render status: 200, json: {:response => "success"}
    elsif params[:identifier]
      Rails.cache.delete("chunk_#{params[:identifier]}")
      Rails.cache.delete("chunk_#{params[:identifier]}_type")
      render status: 200, json: {:response => "success"}
    else
      render status: 404, json: {:response => "no identifier specified"}
    end

  end

end