class Query_Analysis_Mailer < ActionMailer::Base
   
   def notify_user_of_upload_success(user, dataset)
    @base_url = get_base_url
    @user = user
    @dataset = dataset
    mail(:to => ADMIN_CONFIG['email'],
         # Name <email>
         :from => "Queryable RNA-Seq Database Mailer Bot <#{ADMIN_CONFIG['email']}>",
         :reply_to => ADMIN_CONFIG['email'],
         :subject => 'Your Data Upload Was Successful').deliver
    #@url  = "http://example.com/login"
    #mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end
  
  def notify_user_of_upload_failure(user, dataset, error_message, de_tests_count)
    @base_url = get_base_url
    @user = user
    @dataset = dataset
    @error_message = error_message
    @de_tests_count = de_tests_count
    mail(:to => ADMIN_CONFIG['email'],
         # Name <email>
         :from => "Queryable RNA-Seq Database Mailer Bot <#{ADMIN_CONFIG['email']}>",
         :reply_to => ADMIN_CONFIG['email'],
         :subject => 'Your Data Upload Was Unsuccessful').deliver
  end
  
  private
  def get_base_url
    protocol = ActionMailer::Base.default_url_options[:protocol]
    host = ActionMailer::Base.default_url_options[:host]
    return "#{protocol}://#{host}"
  end
end 
