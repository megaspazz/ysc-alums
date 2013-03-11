class TopicsController < ApplicationController

	before_filter: signed_in_user

	def create
		@topic = current_user.topics.build(params[:topic])
		if (@micropost.save)
			flash[:sucess] = "Topic created!"
		end
	end

	def destroy
		@topic.destroy
	end
end
