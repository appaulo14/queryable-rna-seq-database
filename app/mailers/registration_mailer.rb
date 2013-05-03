###
# Mailer class to emails related to user registration.
class RegistrationMailer < ActionMailer::Base
   
   ###
   # Sends an email to all of the administrators stating that 
   # the specified use has requested to register with the system.
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
  end
  
  ###
  # Sends an email to the specified user information them that they have 
  # just been confirmed by the administrator and 
  # that a confirmation email will be sent to them soon. The confirmation email 
  # itself is sent by the Devise gem. 
  def notify_user_that_confirmation_email_will_be_sent(user, optional_note_to_user)
    @report_issue_url = "#{get_base_url}/home/report_issue"
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
  
  ###
  # Sends an email to the specified user stating that their registration 
  # request has been rejected.
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
