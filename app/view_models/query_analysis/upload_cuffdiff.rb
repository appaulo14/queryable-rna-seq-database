require 'tempfile'
require 'open3'
require 'system_util.rb'
require 'upload/blast_util.rb'
require 'upload/go_term_finder_and_processor.rb'

class UploadCuffdiff
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :transcripts_fasta_file, 
                  :transcript_diff_exp_file, 
                  :gene_diff_exp_file, 
                  :transcript_isoforms_file,
                  :has_diff_exp,
                  :has_transcript_isoforms,
                  :dataset_name
 
  #validate :validate_all_or_none_gene_files
  ##Validte for file presence only???
  
#  validates :transcripts_fasta_file, :presence => true,
#                                     :uploaded_file => true
#  
#  validates :has_diff_exp, :presence => true,
#                           :view_model_boolean => true
#  
#  validates :has_transcript_isoforms, :presence => true,
#                                      :view_model_boolean => true
#  
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
        if @has_diff_exp == '1'
          process_gene_differential_expression_file()
          process_transcript_differential_expression_file()
        end
        if @has_transcript_isoforms == '1'
          process_transcript_isoforms_file()
        end
        if (@has_diff_exp == '1' or @has_transcript_isoforms == '1')
          find_and_process_go_terms()
        end
        BlastUtil.create_blast_database(@transcripts_fasta_file.tempfile.path,
                                          @dataset)
      end
    rescue Exception => ex
      BlastUtil.rollback_blast_database(@dataset)
      QueryAnalysisMailer.notify_user_of_upload_failure(@current_user,
                                                          @dataset)
      raise ex
    ensure
      delete_uploaded_files()
    end
    QueryAnalysisMailer.notify_user_of_upload_success(@current_user,
                                                        @dataset)
  end
  
  #According http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
  
  private
  
  #Validations
  def transcripts_fasta_file_is_uploaded_file
    is_uploaded_file('transcripts_fasta_file')
  end
  
  def transcript_diff_exp_file_is_uploaded_file
    is_uploaded_file('transcripts_fasta_file')
  end
  
  def gene_diff_exp_file_is_uploaded_file
    is_uploaded_file('transcripts_fasta_file')
  end
  
  def transcript_isoforms_file_is_uploaded_file
    is_uploaded_file('transcripts_fasta_file')
  end

  def is_uploaded_file(attribute)
    if self.send(attribute).class.to_s != 'ActionDispatch::Http::UploadedFile'
      errors[attribute] << 'must be an uploaded file'
    end
  end
  
  def process_args_to_create_dataset()
    @dataset = Dataset.new(:user => @current_user,
                          :name => @dataset_name,
                          :program_used => 'cuffdiff')
    if @has_diff_exp == '1'
      @dataset.has_transcript_diff_exp = true
      @dataset.has_gene_diff_exp = true
    else
      @dataset.has_transcript_diff_exp = false
      @dataset.has_gene_diff_exp = false
    end
    if @has_transcript_isoforms == '1'
      @dataset.has_transcript_isoforms = true
    else
      @dataset.has_transcript_isoforms = false
    end
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/"
    @dataset.save!
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/#{@dataset.id}"
    @dataset.save!
  end
  
  def process_gene_differential_expression_file()
    @gene_diff_exp_file.tempfile.readline #skip the header line
    while not @gene_diff_exp_file.tempfile.eof?
      line = @gene_diff_exp_file.tempfile.readline
      next if line.blank?
      cells = line.split(/\s+/)
      #Create the gene if not already created
      gene = Gene.where(:dataset_id => @dataset.id,
                         :name_from_program => cells[0])[0]
      if gene.nil?
        gene = Gene.create!(:dataset => @dataset, 
                            :name_from_program => cells[0])
      end
      #Create sample 1 if not already created
      sample_1_name = cells[4]
      sample_1 = Sample.where(:dataset_id => @dataset.id, 
                              :name => sample_1_name)[0]
      if sample_1.nil?
        sample_1 = Sample.create!(:name => sample_1_name, 
                                  :dataset => @dataset)
      end
      #Create sample 2 if not already created
      sample_2_name = cells[5]
      sample_2 = Sample.where(:dataset_id => @dataset.id, 
                              :name => sample_2_name)[0]
      if sample_2.nil?
        sample_2 = Sample.create!(:name => sample_2_name, 
                                  :dataset => @dataset)
      end
      #Create the sample comparison if not already created
      sample_comparison = 
          SampleComparison.where(:sample_1_id => sample_1.id, 
                                :sample_2_id => sample_2.id)[0]
      if sample_comparison.nil?
        sample_comparison = 
            SampleComparison.create!(:sample_1 => sample_1, 
                                    :sample_2 => sample_2)
      end
      #Create the differential expression test
      DifferentialExpressionTest.create!(:gene => gene,
                                          :test_status => cells[6],
                                          :sample_1_fpkm => cells[7],
                                          :sample_2_fpkm => cells[8],
                                          :log_fold_change => cells[9],
                                          :test_statistic => cells[10],
                                          :p_value => cells[11],
                                          :fdr => cells[12],
                                          :sample_comparison => sample_comparison)
    end
  end
  
  def process_transcript_differential_expression_file()
    @transcript_diff_exp_file.tempfile.readline #skip the header line
    while not @transcript_diff_exp_file.tempfile.eof?
      line = @transcript_diff_exp_file.tempfile.readline
      next if line.blank?
      cells = line.split(/\s+/)
      next if cells.blank?
      # Retrieve the transcript's associated gene
      gene = Gene.where(:dataset_id => @dataset.id,
                         :name_from_program => cells[1])[0]
      #Create the transcript if not already created
      transcript = Transcript.where(:dataset_id => @dataset.id,
                                      :name_from_program => cells[0])[0]
      if transcript.nil?
        transcript = Transcript.create!(:dataset => @dataset, 
                                         :name_from_program => cells[0],
                                         :gene => gene)
      end
      #Create sample 1 if not already created
      sample_1_name = cells[4]
      sample_1 = Sample.where(:dataset_id => @dataset.id, 
                              :name => sample_1_name)[0]
      if sample_1.nil?
        sample_1 = Sample.create!(:name => sample_1_name, 
                                  :dataset => @dataset)
      end
      #Create sample 2 if not already created
      sample_2_name = cells[5]
      sample_2 = Sample.where(:dataset_id => @dataset.id, 
                              :name => sample_2_name)[0]
      if sample_2.nil?
        sample_2 = Sample.create!(:name => sample_2_name, 
                                  :dataset => @dataset)
      end
      #Create the sample comparison if not already created
      sample_comparison = 
          SampleComparison.where(:sample_1_id => sample_1.id, 
                                  :sample_2_id => sample_2.id)[0]
      if sample_comparison.nil?
        sample_comparison = 
            SampleComparison.create!(:sample_1 => sample_1, 
                                      :sample_2 => sample_2)
      end
      #Create the differential expression test
      DifferentialExpressionTest.create!(:transcript => transcript,
                                          :test_status => cells[6],
                                          :sample_1_fpkm => cells[7],
                                          :sample_2_fpkm => cells[8],
                                          :log_fold_change => cells[9],
                                          :test_statistic => cells[10],
                                          :p_value => cells[11],
                                          :fdr => cells[12],
                                          :sample_comparison => sample_comparison)
    end
  end
  
  def process_transcript_isoforms_file()
    headers = @transcript_isoforms_file.tempfile.readline.split(/\s+/)
    samples = []
    next_index = 9
    while (next_index < headers.count)
      sample_name = headers[next_index].match(/(.+)_FPKM/).captures[0]
      sample = Sample.where(:dataset_id => @dataset.id,
                               :name => sample_name)[0]
      if sample.nil?
        sample = Sample.create!(:name => sample_name, 
                                 :dataset => @dataset)
      end
      samples << sample
      next_index = next_index + 4
    end
    while not @transcript_isoforms_file.tempfile.eof?
      line = @transcript_isoforms_file.tempfile.readline
      next if line.blank?
      cells = line.split(/\s+/)
      #Create the transcript's associated gene if not already created
      gene = Gene.where(:dataset_id => @dataset.id,
                         :name_from_program => cells[3])[0]
      if gene.nil?
        gene = Gene.create!(:dataset => @dataset,
                             :name_from_program => cells[3])
      end
      #Create the transcript if not already created
      transcript = Transcript.where(:dataset_id => @dataset.id,
                                    :name_from_program => cells[0])[0]
      if transcript.nil?
        transcript = Transcript.create!(:dataset => @dataset,
                             :gene => gene,
                             :name_from_program => cells[0])
      end
#      debugger if not TranscriptFpkmTrackingInformation.class_eval('POSSIBLE_CLASS_CODES').include?(cells[1])
      TranscriptFpkmTrackingInformation.create!(:transcript => transcript,
                                                :class_code => cells[1],
                                                :length => cells[7],
                                                :coverage => cells[8])
      (0..samples.count-1).each do |i|
        sample = samples[i]
        FpkmSample.create!(:transcript => transcript,
                          :sample => sample,
                          :fpkm => cells[9+(4*i)],
                          :fpkm_lo => cells[10+(4*i)],
                          :fpkm_hi => cells[11+(4*i)],
                          :status => cells[12+(4*i)])
      end
    end
  end
  
  def find_and_process_go_terms()
    gtfp = GoTermFinderAndProcessor.new(@transcripts_fasta_file, @dataset)
    gtfp.find_go_terms()
    gtfp.process_go_terms()
  end
  
  def delete_uploaded_files
    if not @transcripts_fasta_file.nil? 
      File.delete(@transcripts_fasta_file.tempfile.path)
    end
    if not @transcript_diff_exp_file.nil?
      File.delete(@transcript_diff_exp_file.tempfile.path)
    end
    if not @gene_diff_exp_file.nil?
      @gene_diff_exp_file.tempfile.close
      File.delete(@gene_diff_exp_file.tempfile.path)
    end
    if not @transcript_isoforms_file.nil?
      File.delete(@transcript_isoforms_file.tempfile.path)
    end
  end
end