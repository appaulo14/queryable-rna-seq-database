###
# Mailer class for emails in the HomeController
class HomeMailer < ActionMailer::Base
   
  ###
  # The number of times to attempt sending an email before giving up and 
  # raising an exception.
  NUMBER_OF_EMAIL_ATTEMPTS = 5
  
   ###
   # Email all the administrator's with information reported in the issue.
   def send_report_on_issue(report_issue)
     @issue_report = report_issue
     admins = User.where(:admin => true)
     raise Exception, "Cannot find any admin users" if admins.empty?
     from = "Queryable RNA-Seq Database Mailer Bot " +
            "<#{MAILER_BOT_CONFIG['email']}>"
     # Send the email, trying multiple times before giving up
     NUMBER_OF_EMAIL_ATTEMPTS.times do |i|
       begin
         mail(:to => User.where(:admin => true).map(&:email),
          :from => from,
          :subject => 'New issue reported').deliver
         break
      rescue Exception => ex
        if i >= NUMBER_OF_EMAIL_ATTEMPTS - 1
          raise
        else
          sleep rand(1..10)
        end
      end
    end
  end
  
  private
  def get_base_url
    protocol = ActionMailer::Base.default_url_options[:protocol]
    host = ActionMailer::Base.default_url_options[:host]
    return "#{protocol}://#{host}"
  end
end 
