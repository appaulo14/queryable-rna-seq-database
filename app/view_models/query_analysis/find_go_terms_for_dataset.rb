require 'tempfile'

class FindGoTermsForDataset
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id
  attr_reader :names_and_ids_for_available_datasets, :datasets_in_progress
  
  validates :dataset_id, :dataset_belongs_to_user => true
  
  def initialize(current_user)
    @current_user = current_user
  end
  
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    #Set available datasets
    @names_and_ids_for_available_datasets = []
    available_datasets = Dataset.where(:user_id => @current_user.id, 
                                        :go_terms_status => 'not-started')
    available_datasets.each do |ds|
      @names_and_ids_for_available_datasets << [ds.name, ds.id]
    end
    #Set default values for the relavent blank attributes
    if @dataset_id.blank?
      @dataset_id = available_datasets.first.id
    end
    @datasets_in_progress = Dataset.where(:user_id => @current_user.id, 
                                           :go_terms_status => 'in-progress')
  end
  
  def find_and_save()
    return if not self.valid?
    @dataset = Dataset.find_by_id(@dataset_id)
    @dataset.go_terms_status = 'in-progress'
    @dataset.save!
    begin
      ActiveRecord::Base.transaction do   #Transactions work with sub-methods 
        find_and_process_go_terms()
        QueryAnalysisMailer.notify_user_of_blast2go_success(@current_user,
                                                              @dataset)
        @dataset.go_terms_status = 'found'
        @dataset.save!
    end
    rescue Exception => ex
      @dataset.go_terms_status = 'not-started'
      @dataset.save!
      QueryAnalysisMailer.notify_user_of_blast2go_failure(@current_user,
                                                            @dataset)
      #Log the exception manually because Rails doesn't want to in this case
      Rails.logger.error "For dataset #{@dataset.id} with name #{@dataset.name}:\n" +
                          "#{ex.message}\n#{ex.backtrace.join("\n")}"
      raise
    end
  end
  
  #According http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
  
  private
  
  def find_and_process_go_terms()
    #Create a fasta file from the blast database
    transcripts_fasta_file = Tempfile.new("transcripts_fasta_file")
    transcripts_fasta_file.close
    SystemUtil.system!("blastdbcmd -entry all " +
                        "-db #{@dataset.blast_db_location} " +
                        "> #{transcripts_fasta_file.path}")
    #Find and process the go terms using the fasta file
    gtfp = GoTermFinderAndProcessor.new(transcripts_fasta_file, @dataset)
    gtfp.find_go_terms()
    gtfp.process_go_terms()
    File.delete(transcripts_fasta_file.path)
  end
end
