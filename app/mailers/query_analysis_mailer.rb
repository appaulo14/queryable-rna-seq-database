class QueryAnalysisMailer < ActionMailer::Base
   
   
   def notify_user_of_upload_success(user, dataset)
    @base_url = get_base_url
    @user = user
    @dataset = dataset
    trancripts_det_count = DifferentialExpressionTest.joins(
      :transcript
    ).where('transcripts.dataset_id' => dataset.id).count
    genes_det_count = DifferentialExpressionTest.joins(
      :gene
    ).where('genes.dataset_id' => dataset.id).count
    @de_tests_count = transcript_det_count + genes_det_count
    mail(:to => @user.email,
         # Name <email>
         :from => "Queryable RNA-Seq Database Mailer Bot <#{MAILER_BOT_CONFIG['email']}>",
         #:reply_to => MAILER_BOT_CONFIG['email'],
         :subject => 'Your Data Upload Was Successful').deliver
    #@url  = "http://example.com/login"
    #mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end
  
  def notify_user_of_upload_failure(user, dataset, error_message)
    @base_url = get_base_url
    @user = user
    @dataset = dataset
    @error_message = error_message
    mail(:to => @user.email,
         # Name <email>
         :from => "Queryable RNA-Seq Database Mailer Bot <#{MAILER_BOT_CONFIG['email']}>",
         #:reply_to => MAILER_BOT_CONFIG['email'],
         :subject => 'Your Data Upload Failed').deliver
  end
  
  private
  def get_base_url
    protocol = ActionMailer::Base.default_url_options[:protocol]
    host = ActionMailer::Base.default_url_options[:host]
    return "#{protocol}://#{host}"
  end
end 
