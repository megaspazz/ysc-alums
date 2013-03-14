class SessionsController < ApplicationController

	def new
	end

	def create
		user = User.find_by_email(params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
      ## assign a code
      ## send a confirmation email
			sign_in(user)
			redirect_back_or(user)
		else
			flash.now[:error] = 'Your login credentials could not be verified!'
			render('new')
		end
	end

	def destroy
		sign_out
		redirect_to(root_url)
	end

	def test
    @user = current_user
    #@confirmed = "a" #current_user.confirmation_code.nil?
	end

end
