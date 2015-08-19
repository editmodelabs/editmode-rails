class ChunksappController < ApplicationController

	def clear_cache

		Rails.cache.delete("chunk_#{params[:identifier]}")
		
		if params[:identifier]
			render status: 200, json: {:response => "success"}
		else
			render status: 404, json: {:response => "no identifier specified"}
		end

	end

end