class Upload_Cuffdiff
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'tempfile'
  require 'open3'
  
  attr_accessor :transcripts_fasta_file, 
                :transcript_diff_exp_file, 
                :gene_diff_exp_file, 
                :transcript_isoforms_file,
                :has_diff_exp,
                :has_transcript_isoforms,
                :dataset_name
  
  attr_reader   :status, :current_user
  
  validates :status, 
      :allow_nil => false, 
      :inclusion => [:not_started, :in_progress, :succeeded, :failed]
  
  #validate :validate_all_or_none_gene_files
  ##Validte for file presence only???
  
  def initialize(current_user)
    @current_user = current_user
    @status = :not_started
  end
  
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
  end
  
  def save!
    return if not self.valid?
    SuckerPunch::Queue[:awesome_queue].async.perform(self)
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
# #       #Run blast2go
# #       blast_xml_output_file = Tempfile.new('blastx')
# #       blast_xml_output_file.close
# #       stdout, stderr, status = 
# #         Open3.capture3("#{Rails.root}/bin/blast/bin/blastx " +
# #                      "-remote -db nr " +
# #                      "-query #{@transcripts_fasta_file.tempfile.path} " +
# #                      "-out #{blast_xml_output_file.path} " +
# #                      "-show_gis -outfmt '5' ")
# #       if not stderr.blank?
# #         raise Exception, stderr
# #       end
# #       blast2go_output_file = Tempfile.new('blast2go')
# #       blast2go_output_file.close
# #       blast2go_dir = "#{Rails.root}/bin/blast2go"
# #       
# #       stdout, stderr, status = 
# #         Open3.capture3("java -Xmx4000m " +
# #                         "-cp *:#{blast2go_dir}/ext/*:#{blast2go_dir}/* " +
# #                         "es.blast2go.prog.B2GAnnotPipe " +
# #                         "-in #{blast_xml_output_file.path} " +
# #                         "-out #{blast2go_output_file.path} " +
# #                         "-prop #{blast2go_dir}/b2gPipe.properties -annot")
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
    
#     child_pid = fork do
#       @status = :in_progress
#       #debugger
#       env = Rails.env
#       n = Dataset.count + 1
#       name = "Dataset_#{n}"
#       de_tests_count = 100
#       #ActiveRecord::Base.connection_pool.with_connection do
#         #ActiveRecord::Base.transaction do
#         Dataset.establish_connection
#         puts "USER count = #{User.count}"
#           ds = Dataset.create!(:user => User.first, 
#                           :name => name,
#                           :program_used => :cuffdiff,
#                           #The Blast database will actually be created later
#                           :blast_db_location => "db/blast_databases/#{env}/#{n}_db",
#                           :has_transcript_diff_exp => true,
#                           :has_transcript_isoforms => true,
#                           :has_gene_diff_exp       => true)
#           Query_Analysis_Mailer.notify_user_of_upload_success(@current_user,
#                                                               ds,
#                                                               de_tests_count)
#           
#           sleep 5
#           #system("echo 'pawlllllllllllllllllllllllllllllllllllll' > ~/PAWL.txt")
#           puts 'hello'
#           puts 'hello'
#           puts 'hello'
#           puts 'hello'
#           puts 'hello'
#           puts 'hello'
#         #end
#         
# #         begin
# #           raise Exception, "This is a raised exception"
# #         rescue Exception => ex
# #           @status = :failed
# #           error_message = 'Insert error message here'
# #           Query_Analysis_Mailer.notify_user_of_upload_failure(@current_user,
# #                                                               ds,
# #                                                               error_message)
# #         end
#   #           if (Process.ppid == 1)
#   #               logger.warn "Parent process is missing. exiting..."
#   #               exit
#   #           end
#       #end
#       exit
#     end
#     puts "returning child pid: #{child_pid}"
#     Process.detach(child_pid)
#     return child_pid
  end
  
#   def perform
#     puts 'hello world'
#     GoTerm.create!(:id => "GO:001", :term => "blah blah")
#     #system("echo 'pawlllllllllllllllllllllllllllllllllllll' > ~/PAWL.txt")
#   end
  
#   def save!
#     debugger if ENV['RAILS_DEBUG'] == 'true'
#     #Create new job
#     job = Job.new(:email => 'nietz111@ksu.edu',
#                   :output_files_type => 'trinity_with_edger')
#     job.save!
#     #TODO: Run blast2go, writing to the genes table?
#     #Read the normalized genes FPKM file, writing to genes and fpkm_samples
#     header_line = gene_fpkm_file.tempfile.readline.strip
#     sample_names = header_line.split("\t")
#     while not gene_fpkm_file.tempfile.eof?
#       line = gene_fpkm_file.tempfile.readline.strip
#       next if line == ""
#       table_cells = line.split("\t")
#       gene_name = table_cells.shift
#       sample_fpkms = table_cells
#       gene = Gene.create!(:job => job, 
#                           :name_from_program => gene_name)
#       (0..sample_fpkms.length-1).each do |i|
#         fpkm_sample = FpkmSample.create!(:gene => gene,
#                                          :sample_name => sample_names[i],
#                                          :fpkm => sample_fpkms[i])
#       end
#     end
#     #Read the normalized transcripts FPKM file, connecting transcripts to genes
#     #   and writing transcripts and fpkm_samples
#     header_line = transcript_fpkm_file.tempfile.readline.strip
#     samples_names = header_line.split("\t")
#     while not transcript_fpkm_file.tempfile.eof? 
#       table_cells = transcript_fpkm_file.tempfile.readline.strip.split("\t")
#       transcript_name = table_cells.shift
#       sample_fpkms = table_cells
#       associated_gene = 
#           Gene.find_by_name_from_program(transcript_name.gsub(/_seq\d+/,""))
#       transcript = Transcript.create!(:job => job, 
#                                       :name_from_program => transcript_name,
#                                       :gene => associated_gene)
#       (0..sample_fpkms.length-1).each do |i|
#         fpkm_sample = FpkmSample.create!(:transcript => transcript,
#                                          :sample_name => sample_names[i],
#                                          :fpkm => sample_fpkms[i])
#       end
#     end
#     #Read the differential expression file for transcripts, 
#     #   writing the differential expression table
#     while not transcript_differential_expression_file.tempfile.eof?
#       line = transcript_differential_expression_file.tempfile.readline.strip
#       next if line.match(/\A#/) #Skip comment linse
#       table_cells = line.split("\t")
#       sample_names = table_cells[0..1]
#       transcript = Transcript.find_by_name_from_program(table_cells[2])
#       different_expression_values = table_cells[3..6]
#       fpkm_sample_1 = 
#           transcript.fpkm_samples.find_by_sample_name(sample_names[0])
#       fpkm_sample_2 = 
#           transcript.fpkm_samples.find_by_sample_name(sample_names[1])
#       differential_expression_test = 
#         DifferentialExpressionTest.create!(:fpkm_sample_1 => fpkm_sample_1,
#                                            :fpkm_sample_2 => fpkm_sample_2,
#                                            :transcript => transcript,
#                                            :log_fold_change => table_cells[4],
#                                            :p_value => table_cells[5],
#                                            :q_value => table_cells[6])
#     end
#     #Read the differential expression file for genes, 
#     #   writing the differential expression table
#       while not gene_differential_expression_file.tempfile.eof?
#       line = gene_differential_expression_file.tempfile.readline.strip
#       next if line.match(/\A#/) #Skip comment linse
#       table_cells = line.split("\t")
#       samples = table_cells[0..1]
#       gene = Gene.find_by_name_from_program(table_cells[2])
#       fpkm_sample_1 = 
#         gene.fpkm_samples.find_by_sample_name(sample_names[0])
#       fpkm_sample_2 = 
#         gene.fpkm_samples.find_by_sample_name(sample_names[1])
#       different_expression_values = table_cells[3..6]
#       differential_expression_test = 
#         DifferentialExpressionTest.create!(:fpkm_sample_1 => fpkm_sample_1,
#                                            :fpkm_sample_2 => fpkm_sample_2,
#                                            :gene => gene,
#                                            :log_fold_change => table_cells[4],
#                                            :p_value => table_cells[5],
#                                            :q_value => table_cells[6])
#     end
#     #Read the Trinity.fasta file, writing to the transcript table
#     line = trinity_fasta_file.tempfile.readline
#     while not trinity_fasta_file.tempfile.eof?
#       #If this is a fasta description line
#       description_line_match = line.match(/\A>(\w+)\s/)
#       transcript_name = description_line_match.captures[0]
#       transcript = Transcript.find_by_name_from_program(transcript_name)
#       transcript.fasta_description = line
#       line = trinity_fasta_file.tempfile.readline
#       transcript.fasta_sequence = ""
#       while not line.match(/\A>/) and not trinity_fasta_file.tempfile.eof?
#         transcript.fasta_sequence << line
#         line = trinity_fasta_file.tempfile.readline
#       end
#       transcript.save!
#     end
#     #Delete the files
#     File.delete(trinity_fasta_file.tempfile.path)
#     File.delete(gene_differential_expression_file.tempfile.path)
#     File.delete(transcript_differential_expression_file.tempfile.path)
#     File.delete(gene_fpkm_file.tempfile.path)
#     File.delete(transcript_fpkm_file.tempfile.path)
#   end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
  
  private
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
