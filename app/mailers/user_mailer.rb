class UserMailer < ActionMailer::Base
  default :from => "admin@yscalumni.org"

  def confirm_email(user)
    @user = user
    @confirm_url = "http://www.yscalumni.org/confirm/" + user.confirmation_code
    mail(:to => user.email, :subject => "Welcome to yscalumni.org! Please confirm your email!")
  end
end
