class UserMailer < ActionMailer::Base

  # Class-static variable representing the YSC alum website admin email address
  @@admin_email = "admin@yscalumni.org"
  
  default :from => @@admin_email

  # The confirmation email, uses default right now
  # Maybe more suitable: confirmation@yscalumni.org or no-reply@yscalumni.org
  def confirm_email(user)
    @user = user
    @confirm_url = "http://www.yscalumni.org/confirm/" + user.confirmation_code
    mail(:to => user.email, :subject => "Welcome to yscalumni.org! Please confirm your email!")
  end

  def admin_confirm_email(user, admin_email_list)
    @user = user
    @confirm_url = "http://www.yscalumni.org/confirm/" + user.confirmation_code
    mail(:to => admin_email_list, :subject => "#{user.name} has requested access to yscalumni.org")
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
  
  def reset_password_email(user, new_password)
    @user = user
    @new_password = new_password
    mail(:to => user.email, :subject => "Your password has been reset")
  end
  
  def email_admin_list(admin_email_list, from_whom, subject, message)
    @message = message
    mail(:from => from_whom, :to => admin_email_list, :subject => subject)
  end
end
