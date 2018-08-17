class StaticPagesController < ApplicationController
	
  def home
  end

  def about
  end

  def help
  end

  def contact
  end
  
  def send_contact_email
    #redirect_to(change_settings_url(current_user))
    #return
    email = params[:email_from].to_s
    if (!(email =~ /\A[\w+\-.]+@[a-zA-Z0-9_]*\.(ru|ae)\z/) && !params[:email_from].blank? && !params[:email_subject].blank? && !params[:email_message].blank?)
      flash[:success] = "Your message has been successfully delivered to the yscalumni.org admins!"
      UserMailer.email_admin_list(get_admin_email_list, params[:email_from], params[:email_subject], params[:email_message]).deliver
      redirect_to(home_url)
    else
      flash.now[:error] = "Check to make sure that none of the fields are blank!"
      render('contact')
    end
  end

  def test
    @test_string = urlsafe_randstr
    @valid_yale = true #has_valid_yale_email(current_user)
    @user = current_user
  end
  VALID_YALE_EMAIL_REGEX = /\A[\w+\-.]+@(aya\.)?yale\.edu\z/i
  def has_valid_yale_email(user)
    VALID_YALE_EMAIL_REGEX === user.email
  end

end
