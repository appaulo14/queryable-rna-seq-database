require 'faker'
require 'bio'
require 'tempfile'

namespace :db do
  namespace :dev do
    desc "Fill database with sample data"
    task :populate => :environment do
      #Generate the data
#      make_admin_user #1
#      make_unconfirmed_users(10)
#       make_datasets('dev') 2
#       make_genes #500
#       make_transcripts_and_blast_databases('dev')
#       make_samples
#       make_sample_comparisons
#       make_fpkm_samples #1000
#       make_transcript_fpkm_tracking_information #1000
#       make_differential_expression_tests #2000
#       make_go_terms #1000
#       make_transcript_has_go_terms #1000
    end
  end
end  
