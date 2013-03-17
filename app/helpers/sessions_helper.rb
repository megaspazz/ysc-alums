module SessionsHelper  # Global helpers

	def sign_in(user)
		cookies.permanent[:remember_token] = user.remember_token
		self.current_user = user
	end

	def signed_in?
		!current_user.nil?
	end

	# This is a before_filter used in both UsersController and SimpleEmailsController
	# to make sure the user is signed in before viewing certain pages or doing certain things
  def signed_in_user
	  unless signed_in?
	    store_location
	    redirect_to(login_url, :notice => "Please sign in")
	  end
	end

	# This is a before_filter used in both UsersController and SimpleEmailsController
	# to make sure the user is confirmed before viewing certain pages or doing certain things
  def check_confirmed_user
    unless confirmed_user? || (self.action_name == 'show' && current_user?(User.find(params[:id])))
		  flash[:error] = "You need need to confirm your email to view this page.  You can resend your confirmation email here."
		  redirect_to(settings_url) # will redirect later
    end
  end
 
  # Checks if the current user is confirmed
	def confirmed_user?
	  current_user.confirmation_code.nil?
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user
		@current_user ||= User.find_by_remember_token(cookies[:remember_token])
	end

	def current_user?(user)
		user == @current_user
	end

	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end

	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url
	end

end
