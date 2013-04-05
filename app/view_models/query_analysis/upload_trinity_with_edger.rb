require 'upload/trinity_transcript_diff_exp_file_processor.rb'
require 'upload/trinity_transcript_fpkm_file_processor.rb'
require 'upload/trinity_gene_diff_exp_file_processor.rb'
require 'upload/trinity_gene_fpkm_file_processor.rb'
require 'upload/go_term_finder_and_processor.rb'
require 'upload/blast_util.rb'

class UploadTrinityWithEdgeR
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :transcripts_fasta_file, 
                  :gene_diff_exp_files, #Array
                  :gene_diff_exp_sample_1_names, #Array
                  :gene_diff_exp_sample_2_names, #Array
                  :transcript_diff_exp_files, #Array 
                  :transcript_diff_exp_sample_1_names, #Array
                  :transcript_diff_exp_sample_2_names, #Array
                  :gene_fpkm_file, 
                  :transcript_fpkm_file,
                  :has_gene_diff_exp,
                  :dataset_name
  
#  validates :transcripts_fasta_file, :presence => true,
#                                     :uploaded_file => true
#  
#  validates :gene_diff_exp_files, :presence => true,
#                                  :array => true,
#                                  :array_of_uploaded_files => true
#  #TODO:Validate name = XvsY???
#  validates :transcript_diff_exp_files, :presence => true,
#                                        :array => true,
#                                        :array_of_uploaded_files => true
#  validate :same_number_of_gene_and_transcript_diff_exp_files
#  
#  validates :gene_fpkm_file, :presence => true,
#                             :uploaded_file => true
#  validates :transcript_fpkm_file, :presence => true,
#                                   :uploaded_file => true
#  validates :dataset_name, :presence => true
#                           :dataset_name_unique_for_user => true
  
  
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
        if @has_gene_diff_exp == '1'
          process_gene_diff_exp_files()
          process_gene_fpkm_file()
        end
        process_transcript_diff_exp_files()
        process_transcript_fpkm_file()
        find_and_process_go_terms()
        BlastUtil.makeblastdb_with_seqids(@transcripts_fasta_file.tempfile.path,
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
      delete_uploaded_files()
    end
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
                            :program_used => 'trinity_with_edger')
    @dataset.has_transcript_diff_exp = true
    if @has_gene_diff_exp == '1'
      @dataset.has_gene_diff_exp = true
    end
    @dataset.has_transcript_isoforms = false
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/"
    @dataset.save!
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/#{@dataset.id}"
    @dataset.save!
  end
  
  def process_gene_diff_exp_files
    @gene_diff_exp_files.count.times do |i|
      gene_diff_exp_file = @gene_diff_exp_files[i]
      sample_1_name = @gene_diff_exp_sample_1_names[i]
      sample_2_name = @gene_diff_exp_sample_2_names[i]
      tgdefp = TrinityGeneDiffExpFileProcessor.new(gene_diff_exp_file,
                                                       @dataset,
                                                       sample_1_name,
                                                       sample_2_name)
      tgdefp.process_file()
    end
  end
  
  def process_gene_fpkm_file
    tgffp = TrinityGeneFpkmFileProcessor.new(@gene_fpkm_file,
                                                 @dataset)
    tgffp.process_file()
  end
  
  def process_transcript_diff_exp_files
    @transcript_diff_exp_files.count.times do |i|
      transcript_diff_exp_file = @transcript_diff_exp_files[i]
      sample_1_name = @transcript_diff_exp_sample_1_names[i]
      sample_2_name = @transcript_diff_exp_sample_2_names[i]
      tdefp = TrinityTranscriptDiffExpFileProcessor.new(transcript_diff_exp_file,
                                                             @dataset,
                                                             sample_1_name,
                                                             sample_2_name)
      tdefp.process_file()
    end
  end
  
  def process_transcript_fpkm_file
    ttffp = TrinityTranscriptFpkmFileProcessor.new(@transcript_fpkm_file,
                                                       @dataset)
    ttffp.process_file()
  end
  
  def find_and_process_go_terms()
    gtfp = GoTermFinderAndProcessor.new(@transcripts_fasta_file, @dataset)
    gtfp.find_go_terms()
    gtfp.process_go_terms()
  end
  
  def delete_uploaded_files
    File.delete(@transcripts_fasta_file.tempfile.path) 
    @gene_diff_exp_files.each do |gene_diff_exp_file|
      File.delete(gene_diff_exp_file.tempfile.path)
    end
    @transcript_diff_exp_files.each do |transcript_diff_exp_file|
      File.delete(transcript_diff_exp_file.tempfile.path)
    end
    if not @gene_fpkm_file.nil?
      File.delete(@gene_fpkm_file.tempfile.path)
    end
    File.delete(@transcript_fpkm_file.tempfile.path)
  end
  
  #### Validations #####
  def same_number_of_gene_and_transcript_diff_exp_files
    return if @gene_diff_exp_files.nil?
    return if @transcript_diff_exp_files.nil?
    return if not @gene_diff_exp_files.kind_of? Array
    return if not @transcript_diff_exp_files.kind_of? Array
    if @gene_diff_exp_files.count != @transcript_diff_exp_files.count
      error_msg = 'transcript and gene differential expression files ' +
                  'must be equal in number'
      errors[:gene_diff_exp_files] << error_msg
      errors[:transcript_diff_exp_files] << error_msg
    end
  end
end
