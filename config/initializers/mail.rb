ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.case.edu',
  :port           => '25',
  :authentication => :login,
  :enable_starttls_auto => true,
}
ActionMailer::Base.delivery_method = :sendmail
