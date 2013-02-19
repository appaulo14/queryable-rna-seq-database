require 'spec_helper'

describe Upload_Trinity_With_EdgeR_Transcripts_And_Genes do
  describe "read the files and writing the data to the database" do
    before(:each) do
#       #Change to the directory of this spec
#       Dir.chdir("#{Rails.root}/spec/view_models/query_analysis")
#       #Make copies of the test files
#       FileUtils.copy('Trinity.fasta','trinity_fasta_file')
#       FileUtils.copy('all_gene_diff_expression_results.txt','gene_det_file')
#       FileUtils.copy('all_transcript_diff_expression_results.txt',
#                     'transcript_det_file')
#       FileUtils.copy('genes.matrix.TMM_normalized.FPKM',
#                     'gene_fpkm_file')
#       FileUtils.copy('transcripts.matrix.TMM_normalized.FPKM',
#                     'transcript_fpkm_file')
#       #Open the test files
#       trintiy_fasta_file = File.new('trinity_fasta_file','r')
#       gene_det_file = File.new('gene_det_file','r')
#       transcript_det_file = File.new('transcript_det_file','r')
#       gene_fpkm_file = File.new('gene_fpkm_file','r')
#       transcript_fpkm_file = 
#         File.new('transcript_fpkm_file','r')
#       #Create the uploaded file objects
#       uploaded_trinity_fasta_file = 
#         ActionDispatch::Http::UploadedFile.new({:tempfile => trintiy_fasta_file})
#       uploaded_gene_det_file = 
#         ActionDispatch::Http::UploadedFile.new({:tempfile => gene_det_file})
#       uploaded_transcript_det_file = 
#         ActionDispatch::Http::UploadedFile.new({:tempfile => transcript_det_file})
#       uploaded_gene_fpkm_file = 
#         ActionDispatch::Http::UploadedFile.new({:tempfile => gene_fpkm_file})
#       uploaded_transcript_fpkm_file = 
#         ActionDispatch::Http::UploadedFile.new(
#           {:tempfile=>transcript_fpkm_file}
#         )
#       @it = Upload_Trinity_With_EdgeR_Transcripts_And_Genes.new()
#       @it.trinity_fasta_file = uploaded_trinity_fasta_file
#       @it.gene_differential_expression_file = uploaded_gene_det_file 
#       @it.transcript_differential_expression_file = uploaded_transcript_det_file
#       @it.gene_fpkm_file = uploaded_gene_fpkm_file
#       @it.transcript_fpkm_file = uploaded_transcript_fpkm_file
    end
    
#     it 'should save without generating any errors' do
#       @it.save!
#     end
#     
#     it 'should add 533 transcripts to the database' do
#       lambda do
#         @it.save!
#       end.should change(Transcript, :count).by(533)
#     end
#     
#     it 'should add 511 genes to the database' do
#       lambda do
#         @it.save!
#       end.should change(Gene, :count).by(511)
#     end
#     
#     it 'should add 1 job to the database' do
#       lambda do
#         @it.save!
#       end.should change(Job, :count).by(1)
#     end
#     
#     it 'should add 282 differential expression tests to the database' do
#       lambda do
#         @it.save!
#       end.should change(DifferentialExpressionTest, :count).by(282)
#     end
#     
# #     it 'should add 4176 amount of fpkm samples to the database' do
# # #       lambda do
# # #         @it.save!
# # #       end.should change(FpkmSample, :count).by(4176)
# #       @it.save!
# #       FpkmSample.should have_exactly(4176).all
# #     end
#     
#     it 'should delete the uploaded files when finished' do
#       @it.save!
#       File.exists?(@it.trinity_fasta_file.tempfile.path).should be_false
#       File.exists?(
#         @it.gene_differential_expression_file.tempfile.path
#       ).should be_false
#       File.exists?(
#         @it.transcript_differential_expression_file.tempfile.path
#       ).should be_false
#       File.exists?(@it.gene_fpkm_file.tempfile.path).should be_false
#       File.exists?(@it.transcript_fpkm_file.tempfile.path).should be_false
#     end
    
#     it 'should associate every transcript with a gene' do
#       @it.save!
#       Transcript.all.each do |transcript|
#         transcript.gene.should_not be_nil
#       end
#     end
    
#     it 'should only write transcripts to the transcripts table' do
#       @it.save!
#       Transcript.all.each do |transcript|
#         transcript.name_from_program.should match(/_seq\d+/)
#       end
#       Gene.all.each do |gene|
#         gene.name_from_program.should_not match(/_seq\d+/)
#       end
#     end
#     
#     it 'should correctly associate transcripts with their genes' do
#       @it.save!
#       Transcript.all.each do |transcript|
#         name_from_transcript = transcript.name_from_program.sub(/_seq\d+/,'')
#         transcript.gene.name_from_program.should match(name_from_transcript)
#       end
#     end
    
    it 'should set all test statuses to "Not available with Trinity"'

    it 'should have go terms'
  
  end
  
  describe 'file validation' do
    describe 'trinity fasta file' do
      it 'should be invalid if the transcript name cannot be parsed ' +
         'from the description line'
      it 'should be invalid if the sequence contains any characters not ' +
         'specified in NCBI\'s fasta format specification'
    end
    describe 'gene differential expression file validation' do
      it 'should be invalid if the file has too many columns'
      it 'should be invalid if the file has too few columns'
      it 'should be invalid if a non-header cell in columns 1 ' +
         'contains characters other than a letter, number, or underscore'
      it 'should be invalid if a non-header cell in columns 2 ' +
         'contains characters other than a letter, number, or underscore'
      it 'should be invalid if a non-header cell in columns 3 ' +
         'contains characters other than a letter, number, or underscore'
      it 'should be invalid if a non-header cell in columns 4 ' +
         'contains non-numeric values'
      it 'should be invalid if a non-header cell in columns 5 ' +
         'contains non-numeric values'
      it 'should be invalid if a non-header cell in columns 6 ' +
         'contains non-numeric values'
      it 'should be invalid if a non-header cell in columns 7 ' +
         'contains non-numeric values'
    end
    describe 'transcript differential expression file validation' do
      it 'should be invalid if the file has too many columns'
      it 'should be invalid if the file has too few columns'
      it 'should be invalid if a non-header cell in columns 1 ' +
         'contains characters other than a letter, number, or underscore'
      it 'should be invalid if a non-header cell in columns 2 ' +
         'contains characters other than a letter, number, or underscore'
      it 'should be invalid if a non-header cell in columns 3 ' +
         'contains characters other than a letter, number, or underscore'
      it 'should be invalid if a non-header cell in columns 4 ' +
         'contains non-numeric values'
      it 'should be invalid if a non-header cell in columns 5 ' +
         'contains non-numeric values'
      it 'should be invalid if a non-header cell in columns 6 ' +
         'contains non-numeric values'
      it 'should be invalid if a non-header cell in columns 7 ' +
         'contains non-numeric values'
    end
    describe 'gene fpkm file validation' do
      it 'should should be invalid if the file does not have at least 3 columns'
      it 'should be invalid if a non-header cell in columns 1 ' +
         'contains characters other than a letter, number, or underscore'
      it 'should be invalid if a non-header cell in any column after ' +
         'the first column contains non-numeric values'
    end
    describe 'transcript fpkm file validation' do
      it 'should should be invalid if the file does not have at least 3 columns'
      it 'should be invalid if a non-header cell in columns 1 ' +
         'contains characters other than a letter, number, or underscore'
      it 'should be invalid if a non-header cell in any column after ' +
         'the first column contains non-numeric values'
    end
  end
#   it 'should create a new instances when given valid attributes' do
#     @transcript.save!
#   end
# 
#   it 'should require a unique id' do
#     @transcript.save!
#     transcript2 = FactoryGirl.build(:transcript)
#     transcript2.id = @transcript.id
#     transcript2.should_not be_valid
#   end
#   
#   it 'should require a fasta sequence'  do
#     @transcript.fasta_sequence = nil
#     @transcript.should_not be_valid
#   end
# 
#   it 'should require a fasta sequence in fasta format' do
#     @transcript.fasta_sequence = 'INVALID FASTA SEQUENCE'
#     @transcript.should_not be_valid
#   end
# 
#   it 'should require a name from the program (ex. cufflinks)' do
#     @transcript.name_from_program = nil
#     @transcript.should_not be_valid
#   end
#   
#   
#   describe 'relationship with a differential expression test' do
#     it 'should require a differential expression test' do
#       @transcript.differential_expression_test = nil
#       @transcript.should_not be_valid
#     end
# 
#     it 'should respond to differential_expression_test' do
#       @transcript.should respond_to(:differential_expression_test)
#     end
# 
# 
#     it 'should be invalid if the associated differential_expression_test ' +
#        'is invalid' do
#       @transcript.differential_expression_test =
#       FactoryGirl.build(:invalid_differential_expression_test)
#       @transcript.should_not be_valid
#     end
#     
#     it 'should destroy its differential expression test when it is destroyed' do
#       @transcript.save!
#       @transcript.destroy
#       @transcript.differential_expression_test.should be_destroyed
#     end
#   end
# 
#   
#   describe 'relationship with a job' do
#     it 'should require a job' do
#       @transcript.job = nil
#       @transcript.should_not be_valid
#     end
# 
#     it 'should be invalid if the associated job is invalid' do
#       @transcript.job =
#         FactoryGirl.build(:invalid_job)
#       @transcript.should_not be_valid
#     end
# 
#     it 'should respond to job' do
#       @transcript.should respond_to(:job)
#     end
#   end
# 
#   
#   describe 'relationship with genes' do
#     it 'should not require a gene' do
#       @transcript.gene = nil
#       @transcript.should be_valid
#     end
# 
#     it 'should be invalid if the associated gene is invalid' do
#       @transcript.gene =
#         FactoryGirl.build(:invalid_gene)
#       @transcript.should_not be_valid
#     end
# 
#     it 'should respond to gene' do
#       @transcript.should respond_to(:gene)
#     end
#     
#     it 'should be invalid when the gene has a different job than it' do
#       @transcript.gene.job = FactoryGirl.create(:job)
#       @transcript.should_not be_valid
#     end
#   end
# 
#   
#   describe 'relationship with fpkm_samples' do
#     it 'should respond to fpkm_samples' do
#       @transcript.should respond_to(:fpkm_samples)
#     end
# 
#     it 'should destroy any dependents from fpkm_samples when it is destroyed' do
#       @transcript.fpkm_samples << FactoryGirl.build(:fpkm_sample,
#                                                     :sample_number => 1,
#                                                     :transcript => @transcript)
#       @transcript.fpkm_samples << FactoryGirl.build(:fpkm_sample,
#                                                     :sample_number => 2,
#                                                     :transcript => @transcript)
#       @transcript.save!
#       @transcript.destroy
#       @transcript.fpkm_samples.each do |fpkm_sample|
#         fpkm_sample.should be_destroyed
#       end
#     end
# 
#     it 'should successfully create a new instance when ' +
#        'fpkm samples are valid' do
#       @transcript.fpkm_samples << FactoryGirl.build(:fpkm_sample,
#                                                     :sample_number => 1,
#                                                     :transcript => @transcript)
#       @transcript.fpkm_samples << FactoryGirl.build(:fpkm_sample,
#                                                     :sample_number => 2,
#                                                     :transcript => @transcript)
#       @transcript.save!
#     end
# 
#     it 'should be invalid when the fpkm_samples are invalid' do
#       @transcript.fpkm_samples << FactoryGirl.build(:invalid_fpkm_sample,
#                                                     :sample_number => 1,
#                                                     :transcript => @transcript)
#       @transcript.fpkm_samples << FactoryGirl.build(:invalid_fpkm_sample,
#                                                     :sample_number => 2,
#                                                     :transcript => @transcript)
#       @transcript.should_not be_valid
#     end
#   end
end
