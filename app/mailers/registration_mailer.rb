 class RegistrationMailer < ActionMailer::Base
  #default :from => "from@example.com"
   def notify_admin_of_registration_request_email(user)
    @user = user
    mail(:to => ADMIN_CONFIG['email'],
         # Name <email>
         :from => "Queryable RNA-Seq Database Mailer Bot <#{ADMIN_CONFIG['email']}>",
         :subject => 'New User Registration Request Received').deliver
    #@url  = "http://example.com/login"
    #mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end
end