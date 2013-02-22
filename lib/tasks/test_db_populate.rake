require 'faker'
require 'bio'
require 'tempfile'

namespace :db do
  namespace :test do 
    desc "Fill database with sample data"
    task :populate => :environment do
      Rake::Task['db:test:prepare'].invoke
      #ActiveRecord::Base.establish_connection('test')
      #Generate the data
      make_admin_user #1
      make_unconfirmed_users(10)
      make_datasets('test') #2
      make_genes #500
      make_transcripts_and_blast_databases('test')
      make_samples
      make_sample_comparisons
      make_fpkm_samples #1000
      make_transcript_fpkm_tracking_information #1000
      make_differential_expression_tests #2000
      make_go_terms #1000
      make_transcript_has_go_terms #1000
    end
  end
end  

