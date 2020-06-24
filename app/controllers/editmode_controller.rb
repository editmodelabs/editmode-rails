class EditmodeController < ApplicationController

  def clear_cache
    if params[:full]
      Rails.cache.clear
      render status: 200, json: {:response => "success"}
    elsif params[:identifier]
      Rails.cache.delete("chunk_#{params[:identifier]}")
      Rails.cache.delete("chunk_#{params[:identifier]}_type")
      Rails.cache.delete("chunk_#{params[:identifier]}_variables")
      render status: 200, json: {:response => "success"}
    else
      render status: 404, json: {:response => "no identifier specified"}
    end

  end

end