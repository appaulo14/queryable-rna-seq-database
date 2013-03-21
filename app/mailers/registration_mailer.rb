class RegistrationMailer < ActionMailer::Base
   
  #default :from => "from@example.com"
   def notify_admin_of_registration_request_email(user)
    @base_url = get_base_url
    @user = user
    User.where(:admin => true).each do |admin|
      from = "Queryable RNA-Seq Database Mailer Bot " +
             "<#{MAILER_BOT_CONFIG['email']}>"
      mail(:to => admin.email,
           # Name <email>
           :from => from,
           :reply_to => MAILER_BOT_CONFIG['email'],
           :subject => 'New User Registration Request Received').deliver
    end
    #@url  = "http://example.com/login"
    #mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end
  
  def notify_user_that_confirmation_email_will_be_sent(user, optional_note_to_user)
    @user = user
    @optional_note_to_user = optional_note_to_user
    subject = 'You Have Been Approved to User the Queryable RNA-Seq Database'
    from = "Queryable RNA-Seq Database Mailer Bot <#{MAILER_BOT_CONFIG['email']}>"
    mail(:to => @user.email,
         # Name <email>
         :from => from,
         :reply_to => MAILER_BOT_CONFIG['email'],
         :subject => subject).deliver
  end
  
  def notify_user_of_rejection(user, optional_note_to_user)
    @user = user
    @optional_note_to_user = optional_note_to_user
    subject = 'Your Account Has Been Dissaproved For Using the ' +
              'Queryable RNA-Seq Database'
    from = "Queryable RNA-Seq Database Mailer Bot <#{MAILER_BOT_CONFIG['email']}>"
    mail(:to => @user.email,
         # Name <email>
         :from => from,
         :reply_to => MAILER_BOT_CONFIG['email'],
         :subject => subject).deliver
  end
  
  private
  def get_base_url
    protocol = ActionMailer::Base.default_url_options[:protocol]
    host = ActionMailer::Base.default_url_options[:host]
    return "#{protocol}://#{host}"
  end
end
