ActionMailer::Base.smtp_settings = {
  :address => "mail.yscalumni.org",
  :port => 587,
  :domain => "yscalumni.org",
  :user_name => "admin@yscalumni.org",
  :password => "praiseGod77",
  :authentication => "plain",
  :enable_starttls_auto => false
}
