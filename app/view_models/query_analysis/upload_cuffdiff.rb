class UploadCuffdiff
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'tempfile'
  require 'open3'
  require 'system_util.rb'
  require 'upload_util.rb'
  
  attr_accessor :transcripts_fasta_file, 
                :transcript_diff_exp_file, 
                :gene_diff_exp_file, 
                :transcript_isoforms_file,
                :has_diff_exp,
                :has_transcript_isoforms,
                :dataset_name
  
  attr_accessor :dataset
  
  #validate :validate_all_or_none_gene_files
  ##Validte for file presence only???
  
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
        UploadUtil.create_blast_database(@transcripts_fasta_file.tempfile.path,@dataset)
        #find_and_process_go_terms()
      end
    rescue Exception => ex
      #UploadUtil.rollback_blast_database_if_exists(@dataset)
#         QueryAnalysisMailer.notify_user_of_upload_failure(@current_user,
#                                                             @dataset,
#                                                             error_message)
      raise ex
    ensure
      delete_files()
    end
#     QueryAnalysisMailer.notify_user_of_upload_success(@current_user,
#                                                       @dataset,
#                                                       de_tests_count)
    #Create the dataset
#     ActiveRecord::Base.transaction do   #Transactions work with sub-methods
#       dataset = Dataset.new(:user => @current_user,
#                             :name => dataset_name,
#                             :program_used => :cuffdiff)
#       if @has_diff_exp == '1'
#         dataset.has_transcript_diff_exp = true
#         dataset.has_gene_diff_exp = true
#       else
#         dataset.has_transcript_diff_exp = false
#         dataset.has_gene_diff_exp = false
#       end
#       if @has_transcript_isoforms == '1'
#         dataset.has_transcript_isoforms = true
#       else
#         dataset.has_transcript_isoforms = false
#       end
#       dataset.blast_db_location = "db/blast_databases/#{Rails.env}/"
#       dataset.save!
#       dataset.blast_db_location = "db/blast_databases/#{Rails.env}/#{dataset.id}"
#       dataset.save!
#       #Read through the gene differential expression file
#       @gene_diff_exp_file.tempfile.readline #skip the header line
#       while not @gene_diff_exp_file.tempfile.eof?
#         line = @gene_diff_exp_file.tempfile.readline
#         next if line.blank?
#         cells = line.split("\t")
#         #Create the genes
#         gene = Gene.create!(:dataset => dataset, 
#                             :name_from_program => cells[0])
#         #Create sample 1 if not already created
#         sample_1_name = cells[4]
#         sample_1 = Sample.where(:dataset_id => dataset.id, 
#                                 :name => sample_1_name)[0]
#         if sample_1.nil?
#           sample_1 = Sample.create!(:name => sample_1_name, 
#                                     :dataset => dataset)
#         end
#         #Create sample 2 if not already created
#         sample_2_name = cells[5]
#         sample_2 = Sample.where(:dataset_id => dataset.id, 
#                                 :name => sample_2_name)[0]
#         if sample_2.nil?
#           sample_2 = Sample.create!(:name => sample_2_name, 
#                                     :dataset => dataset)
#         end
#         #Create the sample comparison if not already created
#         sample_comparison = 
#             SampleComparison.where(:sample_1_id => sample_1.id, 
#                                    :sample_2_id => sample_2.id)[0]
#         if sample_comparison.nil?
#           sample_comparison = 
#               SampleComparison.create!(:sample_1 => sample_1, 
#                                        :sample_2 => sample_2)
#         end
#         #Create the differential expression test
#         DifferentialExpressionTest.create!(:gene => gene,
#                                            :test_status => cells[6],
#                                            :sample_1_fpkm => cells[7],
#                                            :sample_2_fpkm => cells[8],
#                                            :log_fold_change => cells[9],
#                                            :test_statistic => cells[10],
#                                            :p_value => cells[11],
#                                            :fdr => cells[12],
#                                            :sample_comparison => sample_comparison)
#       end
#       #Read through the transcript differential expression file
#       @transcript_diff_exp_file.tempfile.readline #skip the header line
#       while not @transcript_diff_exp_file.tempfile.eof?
#         line = @transcript_diff_exp_file.tempfile.readline
#         next if line.blank?
#         cells = line.split("\t")
#         next if cells.blank?
#         gene = Gene.where(:dataset_id => dataset.id,
#                           :name_from_program => cells[1])[0]
#         transcript = Transcript.create!(:dataset => dataset, 
#                                         :name_from_program => cells[0],
#                                         :gene => gene)
#         #Create sample 1 if not already created
#         sample_1_name = cells[4]
#         sample_1 = Sample.where(:dataset_id => dataset.id, 
#                                 :name => sample_1_name)[0]
#         if sample_1.nil?
#           sample_1 = Sample.create!(:name => sample_1_name, 
#                                     :dataset => dataset)
#         end
#         #Create sample 2 if not already created
#         sample_2_name = cells[5]
#         sample_2 = Sample.where(:dataset_id => dataset.id, 
#                                 :name => sample_2_name)[0]
#         if sample_2.nil?
#           sample_2 = Sample.create!(:name => sample_2_name, 
#                                     :dataset => dataset)
#         end
#         #Create the sample comparison if not already created
#         sample_comparison = 
#             SampleComparison.where(:sample_1_id => sample_1.id, 
#                                    :sample_2_id => sample_2.id)[0]
#         if sample_comparison.nil?
#           sample_comparison = 
#               SampleComparison.create!(:sample_1 => sample_1, 
#                                        :sample_2 => sample_2)
#         end
#         #Create the differential expression test
#         debugger if cells[6].blank?
#         DifferentialExpressionTest.create!(:transcript => transcript,
#                                            :test_status => cells[6],
#                                            :sample_1_fpkm => cells[7],
#                                            :sample_2_fpkm => cells[8],
#                                            :log_fold_change => cells[9],
#                                            :test_statistic => cells[10],
#                                            :p_value => cells[11],
#                                            :fdr => cells[12],
#                                            :sample_comparison => sample_comparison)
#       end
#       #Read through the transcript isoforms file
#       headers = @transcript_isoforms_file.tempfile.readline.split("\t")
#       samples = []
#       next_index = 9
#       while (next_index < headers.count)
#         sample_name = headers[next_index].match(/(.+)_FPKM/).captures[0]
#         samples << Sample.where(:dataset_id => dataset.id,
#                                 :name => sample_name)[0]
#         next_index = next_index + 4
#       end
#       while not @transcript_isoforms_file.tempfile.eof?
#         line = @transcript_isoforms_file.tempfile.readline
#         next if line.blank?
#         cells = line.split("\t")
#         transcript = Transcript.where(:dataset_id => dataset.id,
#                                       :name_from_program => cells[0])[0]
#         TranscriptFpkmTrackingInformation.create!(:transcript => transcript,
#                                                   :class_code => cells[1],
#                                                   :length => cells[7],
#                                                   :coverage => cells[8])
#         if transcript.gene.nil?
#           gene = Gene.where(:dataset_id => dataset.id,
#                             :name_from_program => cells[3])[0]
#           transcript.gene = gene
#         end
#         (0..samples.count-1).each do |i|
#           sample = samples[i]
#           FpkmSample.create!(:transcript => transcript,
#                             :sample => sample,
#                             :fpkm => cells[9+(3*i)],
#                             :fpkm_lo => cells[10+(3*i)],
#                             :fpkm_hi => cells[11+(3*i)],
#                             :status => cells[12+(3*i)])
#         end
#       end
#       #Create Blast database
#       #If this fails and we or it through an exception the transaction will rollback
# #       system("#{Rails.root}/bin/blast/bin/makeblastdb " +
# #             "-in #{@transcripts_fasta_file.tempfile.path} " +
# #             "-title #{dataset.id} " +
# #             "-out #{dataset.blast_db_location} " +
# #             "-hash_index -dbtype nucl ")
# #       
# #       go_terms_file = File.open("#{blast2go_output_file.path}.annot")
#       go_terms_file = File.open('/tmp/blast2go20130302-31641-126n2vl.annot')
#       while not go_terms_file.eof?
#         line = go_terms_file.readline
#         (transcript_name, go_id, term) = line.split("\t")
#         go_term = GoTerm.find_by_id(go_id)
#         if go_term.nil?
#           go_term = GoTerm.create!(:id => go_id, :term => term)
#         end
#         transcript = Transcript.where(:dataset_id => dataset.id, 
#                                       :name_from_program => transcript_name)[0]
#         TranscriptHasGoTerm.create!(:transcript => transcript, 
#                                     :go_term => go_term)
#       end
#       go_terms_file.close
# #       File.delete(go_terms_file.path)
# #       File.delete(blast_xml_output_file.path)
# #       File.delete(blast2go_output_file.path)
#     end
#     #Close the temporary upload files
#     @transcripts_fasta_file.tempfile.close
#     @transcript_diff_exp_file.tempfile.close
#     @gene_diff_exp_file.tempfile.close
#     @transcript_isoforms_file.tempfile.close
#     #Delete the temporary upload files
#     File.delete(@transcripts_fasta_file.tempfile.path)
#     File.delete(@transcript_diff_exp_file.tempfile.path)
#     File.delete(@gene_diff_exp_file.tempfile.path)
#     File.delete(@transcript_isoforms_file.tempfile.path)
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
                          :program_used => :cuffdiff)
    if @has_diff_exp == '1'
      @dataset.has_transcript_diff_exp = true
      @dataset.has_gene_diff_exp = true
    else
      @dataset.has_transcript_diff_exp = false
      @dataset.has_gene_diff_exp = false
    end
    if @has_transcript_isoforms == '1'
      dataset.has_transcript_isoforms = true
    else
      @dataset.has_transcript_isoforms = false
    end
    @dataset.blast_db_location = "#{Rails.root}/db/blast_databases/#{Rails.env}/"
    @dataset.save!
    @dataset.blast_db_location = "#{Rails.root}/db/blast_databases/#{Rails.env}/#{dataset.id}"
    @dataset.save!
  end
  
  def process_gene_differential_expression_file()
    upload_cuffdiff.gene_diff_exp_file.tempfile.readline #skip the header line
    while not upload_cuffdiff.gene_diff_exp_file.tempfile.eof?
      line = upload_cuffdiff.gene_diff_exp_file.tempfile.readline
      next if line.blank?
      cells = line.split("\t")
      #Create the genes
      gene = Gene.create!(:dataset => dataset, 
                          :name_from_program => cells[0])
      #Create sample 1 if not already created
      sample_1_name = cells[4]
      sample_1 = Sample.where(:dataset_id => dataset.id, 
                              :name => sample_1_name)[0]
      if sample_1.nil?
        sample_1 = Sample.create!(:name => sample_1_name, 
                                  :dataset => dataset)
      end
      #Create sample 2 if not already created
      sample_2_name = cells[5]
      sample_2 = Sample.where(:dataset_id => dataset.id, 
                              :name => sample_2_name)[0]
      if sample_2.nil?
        sample_2 = Sample.create!(:name => sample_2_name, 
                                  :dataset => dataset)
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
      cells = line.split("\t")
      next if cells.blank?
      gene = Gene.where(:dataset_id => dataset.id,
                        :name_from_program => cells[1])[0]
      transcript = Transcript.create!(:dataset => dataset, 
                                      :name_from_program => cells[0],
                                      :gene => gene)
      #Create sample 1 if not already created
      sample_1_name = cells[4]
      sample_1 = Sample.where(:dataset_id => dataset.id, 
                              :name => sample_1_name)[0]
      if sample_1.nil?
        sample_1 = Sample.create!(:name => sample_1_name, 
                                  :dataset => dataset)
      end
      #Create sample 2 if not already created
      sample_2_name = cells[5]
      sample_2 = Sample.where(:dataset_id => dataset.id, 
                              :name => sample_2_name)[0]
      if sample_2.nil?
        sample_2 = Sample.create!(:name => sample_2_name, 
                                  :dataset => dataset)
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
      debugger if cells[6].blank?
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
    headers = upload_cuffdiff.transcript_isoforms_file.tempfile.readline.split("\t")
    samples = []
    next_index = 9
    while (next_index < headers.count)
      sample_name = headers[next_index].match(/(.+)_FPKM/).captures[0]
      samples << Sample.where(:dataset_id => dataset.id,
                              :name => sample_name)[0]
      next_index = next_index + 4
    end
    while not upload_cuffdiff.transcript_isoforms_file.tempfile.eof?
      line = upload_cuffdiff.transcript_isoforms_file.tempfile.readline
      next if line.blank?
      cells = line.split("\t")
      transcript = Transcript.where(:dataset_id => dataset.id,
                                    :name_from_program => cells[0])[0]
      TranscriptFpkmTrackingInformation.create!(:transcript => transcript,
                                                :class_code => cells[1],
                                                :length => cells[7],
                                                :coverage => cells[8])
      if transcript.gene.nil?
        gene = Gene.where(:dataset_id => dataset.id,
                          :name_from_program => cells[3])[0]
        transcript.gene = gene
      end
      (0..samples.count-1).each do |i|
        sample = samples[i]
        FpkmSample.create!(:transcript => transcript,
                          :sample => sample,
                          :fpkm => cells[9+(3*i)],
                          :fpkm_lo => cells[10+(3*i)],
                          :fpkm_hi => cells[11+(3*i)],
                          :status => cells[12+(3*i)])
      end
    end
  end
  
  def find_and_process_go_terms()
    go_terms_file_path = 
        UploadUtil.generate_go_terms(@transcripts_fasta_file.tempfile.path)
    go_terms_file = File.open(go_terms_file_path)
    while not go_terms_file.eof?
      line = go_terms_file.readline
      (transcript_name, go_id, term) = line.split("\t")
      go_term = GoTerm.find_by_id(go_id)
      if go_term.nil?
        go_term = GoTerm.create!(:id => go_id, :term => term)
      end
      transcript = Transcript.where(:dataset_id => dataset.id, 
                                    :name_from_program => transcript_name)[0]
      TranscriptHasGoTerm.create!(:transcript => transcript, 
                                  :go_term => go_term)
    end
    go_terms_file.close
    File.delete(go_terms_file.path)
  end
  
  def delete_files
    File.delete(@transcripts_fasta_file.tempfile.path)
    File.delete(@transcript_diff_exp_file.tempfile.path)
    File.delete(@gene_diff_exp_file.tempfile.path)
    File.delete(@transcript_isoforms_file.tempfile.path)
  end
  
  def validate_trinity_fasta_file
    #Validate that transcript name can be captured from description line?
  end
  
  def validate_transcript_differential_expression_file
    #Ensure this is a file before parsing it
#     return if trinity_fasta_file.nil?
#     if not trinity_fasta_file.kind_of? ActionDispatch::Http::UploadedFile
#       errors[:trinity_fasta_file] << "Must be a file."
#       return
#     end
#     
#     #loop through the file.
#     debugger if ENV['RAILS_DEBUG'] == 'true'
#     trinity_fasta_file.tempfile
    #Must have 7 columns
    #Last 4 columns must be convertable to double types
  end
  
  def validate_gene_differential_expression_file
  end
  
  def validate_transcript_fpkm_file
    #Confirm at least two samples in header column
    #Confirm all rows have the right number of fpkm_samples
  end
  
  def validate_gene_fpkm_file
  end
  
  def validate_all_or_none_gene_files
    #User should upload both gene files or neither
  end
end
