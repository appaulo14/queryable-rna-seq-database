###
# Mailer class for emails in the QueryAnalysisController
class QueryAnalysisMailer < ActionMailer::Base
 
   ###
   # Sends an email to the specified user that the specified dataset was 
   # successfully uploaded.
   def notify_user_of_upload_success(user, dataset)
    @base_url = get_base_url()
    @user = user
    @dataset = dataset
    #Calculate the number of datasets uploaded
    transcripts_det_count = DifferentialExpressionTest.joins(
      :transcript
    ).where('transcripts.dataset_id' => dataset.id).count
    genes_det_count = DifferentialExpressionTest.joins(
      :gene
    ).where('genes.dataset_id' => dataset.id).count
    @de_tests_count = transcripts_det_count + genes_det_count
    #Calculate the sample comparisons
    s_t = Sample.arel_table
    where_clause = s_t[:dataset_id].eq(@dataset.id)
    if @dataset.program_used == 'trinity_with_edger'
      @transcript_sample_comparisons_count =  SampleComparison
          .joins(:sample_1,:sample_2)
          .where(where_clause.and(s_t[:sample_type].eq('transcript')))
          .select('COUNT(*) as count')[0].count
      @gene_sample_comparisons_count =  SampleComparison
          .joins(:sample_1,:sample_2)
          .where(where_clause.and(s_t[:sample_type].eq('gene')))
          .select('COUNT(*) as count')[0].count
    else
      where_clause = s_t[:dataset_id].eq(@dataset.id)
      @sample_comparisons_count = SampleComparison.joins(:sample_1,:sample_2).
          where(where_clause).select('COUNT(*) as count')[0].count
    end
    #Calculate the number of transcripts uploaded
    @fpkm_sample_count = FpkmSample.joins(
      :transcript
    ).where('transcripts.dataset_id' => dataset.id).count
    #Calculate the number of GO terms
    @go_terms_count = TranscriptHasGoTerm.joins(
      :transcript
    ).where('transcripts.dataset_id' => dataset.id).count 
    mail(:to => @user.email,
         # Name <email>
         :from => mailer_bot_from_field(),
         #:reply_to => MAILER_BOT_CONFIG['email'],
         :subject => 'Your Data Upload Was Successful').deliver
    #@url  = "http://example.com/login"
    #mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end
  
  ###
  # Sends an email to the specified user that the specified dataset did not 
  # upload successfully.
  def notify_user_of_upload_failure(user, dataset)
    @base_url = get_base_url()
    @report_issue_url = "#{@base_url}/home/report_issue"
    @user = user
    @dataset = dataset
    mail(:to => @user.email,
         # Name <email>
         :from => mailer_bot_from_field(),
         #:reply_to => MAILER_BOT_CONFIG['email'],
         :subject => 'Your Data Upload Failed').deliver
  end
  
  ###
  # Sends an email to the specified user that the specified dataset had its 
  # go terms found successfully.
  def notify_user_of_blast2go_success(user, dataset)
    @base_url = get_base_url()
    @user = user
    @dataset = dataset
    @go_terms_count = TranscriptHasGoTerm.joins(
      :transcript
    ).where('transcripts.dataset_id' => dataset.id).count 
    mail(:to => @user.email,
         # Name <email>
         :from => mailer_bot_from_field(),
         #:reply_to => MAILER_BOT_CONFIG['email'],
         :subject => 'Finding Your Gene Ontology (GO) Terms Was Successful').deliver
  end
  
  ###
  # Sends an email to the specified user that the specified dataset failed to 
  # have its go terms found.
  def notify_user_of_blast2go_failure(user, dataset)
    @base_url = get_base_url()
    @user = user
    @dataset = dataset
    @report_issue_url = "#{@base_url}/home/report_issue"
    mail(:to => @user.email,
         # Name <email>
         :from => mailer_bot_from_field(),
         #:reply_to => MAILER_BOT_CONFIG['email'],
         :subject => 'Finding Your Gene Ontology (GO) Terms Failed').deliver
  end
  
  def send_blast_report(query_using_blast,blast_report,user)
    # Declare some variables to use with the views
    @bq = query_using_blast
    @dataset = Dataset.find_by_id(query_using_blast.dataset_id)
    @program = blast_report.program.capitalize()
    @user = user
    # Render the blast results as an attachment to the email
    view = ActionView::Base.new( 'app/views/query_analysis')
    view.instance_variable_set('@blast_report',blast_report)
    view.instance_variable_set('@dataset',@dataset)
    results_string = view.render({:template => 'blast_results'})
    compressed_results_string = ActiveSupport::Gzip.compress(results_string)
    attachment_name = "#{blast_report.program}_results_for_" +
                      "#{@dataset.name}.html.gz"
    attachments[attachment_name] = compressed_results_string
    # Create the email's subject
    subject = "#{blast_report.program.capitalize()} " +
              "Results for Dataset \"#{@dataset.name}\""
    # Send the email
    mail(:to => user.email,
         :from => mailer_bot_from_field(),
         :subject => subject ).deliver
  end
  
  def send_blast_failure_message(query_using_blast,user)
    @bq = query_using_blast
    @dataset = Dataset.find_by_id(query_using_blast.dataset_id)
    @program = query_using_blast.class.get_program_name.capitalize()
    @user = user
    @report_issue_url = "#{get_base_url()}/home/report_issue"
    subject = "#{@program.capitalize()} " +
              "for Dataset \"#{@dataset.name}\" Failed"
    # Send the email
    mail(:to => user.email,
         :from => mailer_bot_from_field(),
         :subject => subject ).deliver
  end
  
  def send_query_regular_db_results(query_regular_db, user)
    # Define some variables to use with the view
    @query_regular_db = query_regular_db
    @dataset = Dataset.find_by_id(query_regular_db.dataset_id)
    @user = user
    @query_type = query_regular_db.class.get_query_type()
    if query_regular_db.respond_to?('sample_id')
      @sample_name = Sample.find_by_id(query_regular_db.sample_id).name
    end
    if query_regular_db.respond_to?('sample_comparison_id')
      sample_cmp = SampleComparison.find_by_id(query_regular_db.sample_comparison_id)
      sample_1_name = sample_cmp.sample_1.name
      sample_2_name = sample_cmp.sample_2.name
      @sample_cmp_name = "#{sample_1_name} vs #{sample_2_name}"
    end
    # If there are results, create, compress, and attach the results file
    if not query_regular_db.results.empty?
#       results_string = query_regular_db.results[0].attributes.keys.join("\t")
#       results_string += "\n"
#       query_regular_db.results.each do |result|
#         results_string += "#{result.attributes.values.join("\t")}\n"
#       end
      # Render the blast results as an attachment to the email
      view = ActionView::Base.new( 'app/views/query_analysis_mailer')
      view.instance_variable_set('@results',query_regular_db.results)
      results_string = view.render({:template => 'query_regular_db_results'})
      compressed_results_string = ActiveSupport::Gzip.compress(results_string)
      attachment_name = "#{@query_type}_results_for_" +
                        "#{@dataset.name}.txt.gz"
      attachments[attachment_name] = compressed_results_string
    end
    # Create the email's subject
    subject = "#{@query_type.capitalize()} " +
              "Results for Dataset \"#{@dataset.name}\""
    # Send the email
    mail(:to => user.email,
         :from => mailer_bot_from_field(),
         :subject => subject ).deliver
  end
  
  def send_query_regular_db_failure_message(query_regular_db, user)
    @query_regular_db = query_regular_db
    @dataset = Dataset.find_by_id(query_regular_db.dataset_id)
    @user = user
    @query_type = query_regular_db.class.get_query_type()
    if query_regular_db.respond_to?('sample_id')
      @sample_name = Sample.find_by_id(query_regular_db.sample_id).name
    end
    if query_regular_db.respond_to?('sample_comparison_id')
      sample_cmp = SampleComparison.find_by_id(query_regular_db.sample_comparison_id)
      sample_1_name = sample_cmp.sample_1.name
      sample_2_name = sample_cmp.sample_2.name
      @sample_cmp_name = "#{sample_1_name} vs #{sample_2_name}"
    end
    @report_issue_url = "#{get_base_url()}/home/report_issue"
    subject = "#{@query_type.capitalize()} " +
              "for Dataset \"#{@dataset.name}\" Failed"
    # Send the email
    mail(:to => user.email,
         :from => mailer_bot_from_field(),
         :subject => subject ).deliver
  end
  
  private
  
  def get_base_url
    protocol = ActionMailer::Base.default_url_options[:protocol]
    host = ActionMailer::Base.default_url_options[:host]
    return "#{protocol}://#{host}"
  end
  
  def mailer_bot_from_field
    return "Queryable RNA-Seq Database Mailer Bot <#{MAILER_BOT_CONFIG['email']}>"
  end
end 
