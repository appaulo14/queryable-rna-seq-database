require 'upload/blast_util.rb'

###
# View model for the upload fasta sequences page.
#
# <b>Associated Controller:</b> QueryAnalysisController
#
# <b>Associated Worker:</b> WorkerForUploadFastaSequences
class UploadFastaSequences
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  # The uploaded file containing the fasta sequences for the 
  # assembled transcripts
  attr_accessor :transcripts_fasta_file
  # The name to give to the uploaded dataset
  attr_accessor :dataset_name
                  
  validates :transcripts_fasta_file, :presence => true,
                                     :uploaded_file => true,
                                     :has_fasta_file_extension => true
  validates :dataset_name, :presence => true,
                           :dataset_name_unique_for_user => true
  
  ###
  # parameters::
  # * <b>current_user:</b> The currently logged in user
  def initialize(current_user)
    @current_user = current_user
  end
  
  # Set the view model's attributes or set those attributes to their 
  # default values
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
  end
  
  # Saves the data from the uploaded file(s) into the database under a dataset 
  # named #dataset_name
  def save
    return if not self.valid?
    begin
      ActiveRecord::Base.transaction do   #Transactions work with sub-methods 
        process_args_to_create_dataset()
        BlastUtil.makeblastdb_without_seqids(@transcripts_fasta_file.tempfile.path,
                                              @dataset)
        finalize_dataset()
        QueryAnalysisMailer.notify_user_of_upload_success(@current_user,
                                                        @dataset)
      end
    rescue Exception => ex
      BlastUtil.rollback_blast_database(@dataset)
      QueryAnalysisMailer.notify_user_of_upload_failure(@current_user,
                                                          @dataset)
      #Log the exception manually because Rails doesn't want to in this case
      Rails.logger.error "For dataset #{@dataset.id} with name #{@dataset.name}:\n" +
                          "#{ex.message}\n#{ex.backtrace.join("\n")}"
      raise
    ensure
      File.delete(@transcripts_fasta_file.tempfile.path)
    end
  end
  
  # According to http://railscasts.com/episodes/219-active-model?view=asciicast,
  # this defines that this view model does not persist in the database.
  def persisted?
      return false
  end 
  
  private 
  
  def process_args_to_create_dataset()
    @dataset = Dataset.new(:user => @current_user,
                            :name => @dataset_name,
                            :program_used => 'generic_fasta_file',
                            :finished_uploading => false)
    @dataset.has_transcript_diff_exp = false
    @dataset.has_gene_diff_exp = false
    @dataset.has_transcript_isoforms = false
    @dataset.go_terms_status = 'not-applicable'
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/"
    @dataset.save!
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/#{@dataset.id}"
    @dataset.save!
  end
  
  def finalize_dataset()
    @dataset.finished_uploading = true
    @dataset.save!
  end
end
