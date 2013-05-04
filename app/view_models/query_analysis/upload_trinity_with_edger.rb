require 'upload/trinity_transcript_diff_exp_file_processor.rb'
require 'upload/trinity_transcript_fpkm_file_processor.rb'
require 'upload/trinity_gene_diff_exp_file_processor.rb'
require 'upload/trinity_gene_fpkm_file_processor.rb'
require 'upload/go_term_finder_and_processor.rb'
require 'upload/blast_util.rb'

###
# View model for the upload Trinity with EdgeR page.
#
# <b>Associated Controller:</b> QueryAnalysisController
#
# <b>Associated Worker:</b> WorkerForUploadTrinityWithEdgeR
class UploadTrinityWithEdgeR
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  # The uploaded file containing the fasta sequences for the 
  # assembled transcripts
  attr_accessor :transcripts_fasta_file 
  # A collection of the uploaded files containing the gene differential 
  # expression tests
  attr_accessor :gene_diff_exp_files #Array
  # A collection of the sample names for the first sample of the gene 
  # differential expression test files with the corresponding array indexes.
  attr_accessor :gene_diff_exp_sample_1_names #Array
  # A collection of the sample names for the second sample of the gene 
  # differential expression test files with the corresponding array indexes.
  attr_accessor :gene_diff_exp_sample_2_names #Array
  # A collection of the uploaded files containing the transcript differential 
  # expression tests
  attr_accessor :transcript_diff_exp_files #Array 
  # A collection of the sample names for the first sample of the transcript 
  # differential expression test files with the corresponding array indexes.
  attr_accessor :transcript_diff_exp_sample_1_names #Array
  # A collection of the sample names for the first sample of the transcript 
  # differential expression test files with the corresponding array indexes.
  attr_accessor :transcript_diff_exp_sample_2_names #Array
  # An uploaded file containing the fpkms for all genes and all the samples
  attr_accessor :gene_fpkm_file
  # An uploaded file containing the fpkms for all transcripts and all the 
  # samples
  attr_accessor :transcript_fpkm_file
  # Whether or not gene differential expression tests and fpkms will be 
  # uploaded 
  attr_accessor :has_gene_diff_exp
  # The name to give to the uploaded dataset
  attr_accessor :dataset_name
  
  validates :transcripts_fasta_file, :presence => true,
                                     :uploaded_file => true,
                                     :name_is_trinity_fasta => true
  
  validates :gene_diff_exp_files, :array => true,
                                  :array_of_uploaded_files => true
  validates :gene_diff_exp_files, :presence => true,
                                  :if => "@has_gene_diff_exp == '1'"
  validates :gene_diff_exp_sample_1_names, :array => true
  validates :gene_diff_exp_sample_1_names, :presence => true,
                                           :array_elements_are_not_empty => true,
                                           :if => "@has_gene_diff_exp == '1'"
  validates :gene_diff_exp_sample_2_names, :array => true
  validates :gene_diff_exp_sample_2_names, :presence => true,
                                           :array_elements_are_not_empty => true,
                                           :if => "@has_gene_diff_exp == '1'"
  validates :transcript_diff_exp_files, :presence => true,
                                        :array => true,
                                        :array_of_uploaded_files => true
  validates :transcript_diff_exp_sample_1_names, :presence => true,
                                                 :array => true,
                                                 :array_elements_are_not_empty => true
  validates :transcript_diff_exp_sample_2_names, :presence => true,
                                                 :array => true,
                                                 :array_elements_are_not_empty => true
  
  validates :gene_fpkm_file, :uploaded_file => true
  validates :gene_fpkm_file, :presence => true,
                             :if => "@has_gene_diff_exp == '1'"
  validates :transcript_fpkm_file, :presence => true,
                                   :uploaded_file => true
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
  
  # Saves the data from the uploaded files into the database under a dataset 
  # named #dataset_name
  def save
    return if not self.valid?
    begin
      #ActiveRecord::Base.transaction do   #Transactions work with sub-methods
        process_args_to_create_dataset()
        Rails.logger.info "Created dataset #{@dataset.id} for #{@dataset_name}"
        if @has_gene_diff_exp == '1'
          Rails.logger.info "Starting gene diff exp for dataset: #{@dataset.id}"
          process_gene_diff_exp_files()
          Rails.logger.info "Finished gene diff exp for dataset: #{@dataset.id}"
          Rails.logger.info "Starting gene fpkm for dataset: #{@dataset.id}"
          process_gene_fpkm_file()
          Rails.logger.info "Finished gene fpkm exp for dataset: #{@dataset.id}"
        end
        Rails.logger.info "Started trans diff exp for dataset: #{@dataset.id}"
        process_transcript_diff_exp_files()
        Rails.logger.info "Finished trans diff exp for dataset: #{@dataset.id}"
        Rails.logger.info "Starting trans fpkm for dataset: #{@dataset.id}"
        process_transcript_fpkm_file()
        Rails.logger.info "Finished trans fpkm exp for dataset: #{@dataset.id}"
        Rails.logger.info "Started blast db creation for dataset: #{@dataset.id}"
        BlastUtil.makeblastdb_with_seqids(@transcripts_fasta_file.tempfile.path,
                                           @dataset)
        Rails.logger.info "Finished blast db creation for dataset: #{@dataset.id}"
        @dataset.finished_uploading = true
        @dataset.save!
        QueryAnalysisMailer.notify_user_of_upload_success(@current_user,
                                                            @dataset)                                        
      #end
      #If any error occurs, the files won't be deleted and therefore can
      # be examined for problems
      delete_uploaded_files()
    rescue Exception => ex
      begin
        @dataset.delete()
        BlastUtil.rollback_blast_database(@dataset)
        QueryAnalysisMailer.notify_user_of_upload_failure(@current_user,
                                                          @dataset)
      #Log the exception manually because Rails doesn't want to in this case
      rescue Exception => ex2
        Rails.logger.error "For dataset #{@dataset.id} with name #{@dataset.name}:\n" +
                          "#{ex2.message}\n#{ex2.backtrace.join("\n")}"
        raise ex2, ex2.message
      ensure
        Rails.logger.error "For dataset #{@dataset.id} with name #{@dataset.name}:\n" +
                          "#{ex.message}\n#{ex.backtrace.join("\n")}"
      end
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
                           :program_used => 'trinity_with_edger',
                           :finished_uploading => false)
    @dataset.has_transcript_diff_exp = true
    if @has_gene_diff_exp == '1'
      @dataset.has_gene_diff_exp = true
    else
      @dataset.has_gene_diff_exp = false
    end
    @dataset.has_transcript_isoforms = false
    @dataset.go_terms_status = 'not-started'
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
    gtfp = GoTermFinderAndProcessor.new(@transcripts_fasta_file.tempfile,
                                           @dataset)
    gtfp.find_go_terms()
    gtfp.process_go_terms()
  end
  
  def delete_uploaded_files
    File.delete(@transcripts_fasta_file.tempfile.path)
    if not @gene_diff_exp_files.nil?
      @gene_diff_exp_files.each do |gene_diff_exp_file|
        File.delete(gene_diff_exp_file.tempfile.path)
      end
    end
    @transcript_diff_exp_files.each do |transcript_diff_exp_file|
      File.delete(transcript_diff_exp_file.tempfile.path)
    end
    if not @gene_fpkm_file.nil?
      File.delete(@gene_fpkm_file.tempfile.path)
    end
    File.delete(@transcript_fpkm_file.tempfile.path)
  end
end
