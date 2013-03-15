class UserMailer < ActionMailer::Base
  default :from => "admin@yscalumni.org"

  # The confirmation email, uses default right now
  # Maybe more suitable: confirmation@yscalumni.org or no-reply@yscalumni.org
  def confirm_email(user)
    @user = user
    @confirm_url = "http://www.yscalumni.org/confirm/" + user.confirmation_code
    mail(:to => user.email, :subject => "Welcome to yscalumni.org! Please confirm your email!")
  end

  # Anonymously send the alum the specified email
  def send_to_alum(email)
    @email = email
    mail(:from => email.user_email, :to => email.alum_email, :subject => email.subject)
  end

  # Notify the user that the email has been successfully sent
  def send_to_user(email)
    @email = email
    mail(:to => email.user_email, :subject => 'Your email has been sent!')
  end
end
