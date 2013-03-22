class HomeMailer < ActionMailer::Base
   
   
   def send_report_on_issue(report_issue)
     @issue_report = report_issue
     admins = User.where(:admin => true)
     raise Exception, "Cannot find any admin users" if admins.empty?
     from = "Queryable RNA-Seq Database Mailer Bot " +
            "<#{MAILER_BOT_CONFIG['email']}>"
     admins.each do |admin|
       @admin = admin
       mail(:to => @admin.email,
          :from => from,
          :subject => 'New issue reported').deliver
     end
  end
  
  private
  def get_base_url
    protocol = ActionMailer::Base.default_url_options[:protocol]
    host = ActionMailer::Base.default_url_options[:host]
    return "#{protocol}://#{host}"
  end
end 
