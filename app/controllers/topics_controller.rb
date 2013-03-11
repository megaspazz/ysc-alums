class TopicsController < ApplicationController

	before_filter: signed_in_user

	def create
		@topic = current_user.topics.build(params[:topic])
	end

	def destroy

	end
end
