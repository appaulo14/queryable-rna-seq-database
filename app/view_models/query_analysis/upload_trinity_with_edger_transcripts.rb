class UploadTrinityWithEdgeRTranscripts
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  require 'upload/trinity_transcript_diff_exp_file_processor.rb'
  require 'upload/trinity_transcript_fpkm_file_processor.rb'

  attr_accessor :transcripts_fasta_file, 
                :transcript_diff_exp_files, #Array 
                :transcript_fpkm_file,
                :dataset_name
  
  validates :transcripts_fasta_file, :presence => true,
                                     :uploaded_file => true
  validates :transcript_diff_exp_files, :presence => true,
                                        :array => true,
                                        :array_of_uploaded_files => true
  validates :transcript_fpkm_file, :presence => true,
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
        process_transcript_diff_exp_files()
        process_transcript_fpkm_file()
        #find_and_process_go_terms()
        UploadUtil.create_blast_database(@transcripts_fasta_file.tempfile.path,
                                          @dataset)
      end
    rescue Exception => ex
      UploadUtil.rollback_blast_database(@dataset)
      QueryAnalysisMailer.notify_user_of_upload_failure(@current_user,
                                                          @dataset,
                                                          ex.message)
      raise ex
    ensure
      delete_uploaded_files()
    end
    QueryAnalysisMailer.notify_user_of_upload_success(@current_user,
                                                        @dataset)
  end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
  
  private 
  
  def process_args_to_create_dataset()
    @dataset = Dataset.new(:user => @current_user,
                            :name => @dataset_name,
                            :program_used => :trinity_with_edger)
    @dataset.has_transcript_diff_exp = true
    @dataset.has_gene_diff_exp = false
    @dataset.has_transcript_isoforms = false
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/"
    @dataset.save!
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/#{@dataset.id}"
    @dataset.save!
  end
  
  def process_transcript_diff_exp_files
    @transcript_diff_exp_files.each do |transcript_diff_exp_file|
      #Process the file
      tdefp = TrinityTranscriptDiffExpFileProcessor.new(transcript_diff_exp_file,
                                                        @dataset)
      tdefp.process_file()
    end
  end
  
  def process_transcript_fpkm_file
    ttffp = TrinityTranscriptFpkmFileProcessor.new(@transcript_fpkm_file,
                                                    @dataset)
    ttffp.process_file()
  end
  
  def find_and_process_go_terms()
    go_terms_file_path = 
        UploadUtil.generate_go_terms(@transcripts_fasta_file.tempfile.path)
    go_terms_file = File.open(go_terms_file_path)
    while not go_terms_file.eof?
      line = go_terms_file.readline
      next if line.blank?
      line_regex = /\A(\S+)\s+(\S+)\s+(.+)\z/
      (transcript_name, go_id, term) = line.strip.match(line_regex).captures
      go_term = GoTerm.find_by_id(go_id)
      if go_term.nil?
        go_term = GoTerm.create!(:id => go_id, :term => term)
      end
      transcript = Transcript.where(:dataset_id => @dataset.id, 
                                    :name_from_program => transcript_name)[0]
      TranscriptHasGoTerm.create!(:transcript => transcript, 
                                     :go_term => go_term)
    end
    go_terms_file.close
    File.delete(go_terms_file.path)
  end
  
  def delete_uploaded_files
    File.delete(@transcripts_fasta_file.tempfile.path) 
    @transcript_diff_exp_files.each do |transcript_diff_exp_file|
      File.delete(transcript_diff_exp_file.tempfile.path)
    end
    File.delete(@transcript_fpkm_file.tempfile.path)
  end
end
