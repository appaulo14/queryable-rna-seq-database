require 'upload/blast_util.rb'

class UploadFastaSequences
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :transcripts_fasta_file, 
                  :dataset_name
                  
  validates :transcripts_fasta_file, :presence => true,
                                     :uploaded_file => true
  validates :dataset_name, :presence => true
  
  def initialize(current_user)
    @current_user = current_user
  end
  
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
  end
  
  def save
     return if not self.valid?
    begin
      ActiveRecord::Base.transaction do   #Transactions work with sub-methods 
        process_args_to_create_dataset()
        BlastUtil.makeblastdb_without_seqids(@transcripts_fasta_file.tempfile.path,
                                              @dataset)
        QueryAnalysisMailer.notify_user_of_upload_success(@current_user,
                                                        @dataset)
      end
    rescue Exception => ex
      BlastUtil.rollback_blast_database(@dataset)
      QueryAnalysisMailer.notify_user_of_upload_failure(@current_user,
                                                          @dataset)
      #Log the exception manually because Rails doesn't want to in this case
      Rails.logger.error "#{ex.message}\n#{ex.backtrace.join("\n")}"
      raise
    ensure
      File.delete(@transcripts_fasta_file.tempfile.path)
    end
  end
  
  #According http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end 
  
  private 
  
  def process_args_to_create_dataset()
    @dataset = Dataset.new(:user => @current_user,
                            :name => @dataset_name,
                            :program_used => 'generic_fasta_file')
    @dataset.has_transcript_diff_exp = false
    @dataset.has_gene_diff_exp = false
    @dataset.has_transcript_isoforms = false
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/"
    @dataset.save!
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/#{@dataset.id}"
    @dataset.save!
  end
end
