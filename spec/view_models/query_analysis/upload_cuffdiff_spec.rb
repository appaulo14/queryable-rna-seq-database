require 'spec_helper'

describe Upload_Cuffdiff do
  before(:all) do 
    #Change to the directory of this spec
    Dir.chdir("#{Rails.root}/spec/view_models/query_analysis")
    #Make copies of the test files
#     FileUtils.copy('cuff_transcripts.fasta','cuffdiff_fasta_file')
#     FileUtils.copy('isoform_exp.diff','transcript_diff_exp_file')
#     FileUtils.copy('gene_exp.diff', 'gene_diff_exp_file')
#     FileUtils.copy('isoforms.fpkm_tracking','transcript_isoform_file')
    FileUtils.copy('cuff_transcripts.fasta','cuffdiff_fasta_file')
    FileUtils.copy('/media/sf_MSE_Project/Workshop_Of_Paul/Reference_Worflow/cuffdiff_output/isoform_exp.diff','transcript_diff_exp_file')
    FileUtils.copy('/media/sf_MSE_Project/Workshop_Of_Paul/Reference_Worflow/cuffdiff_output/gene_exp.diff', 'gene_diff_exp_file')
    FileUtils.copy('/media/sf_MSE_Project/Workshop_Of_Paul/Reference_Worflow/cuffdiff_output/isoforms.fpkm_tracking','transcript_isoform_file')
    #Open the test files
    cuffdiff_fasta_file = File.new('cuffdiff_fasta_file','r')
    transcript_diff_exp_file = File.new('transcript_diff_exp_file','r')
    gene_diff_exp_file = File.new('gene_diff_exp_file','r')
    transcript_isoform_file = File.new('transcript_isoform_file','r')
    #Create the uploaded file objects
    uploaded_fasta_file = 
      ActionDispatch::Http::UploadedFile.new({:tempfile=>cuffdiff_fasta_file})
    uploaded_transcript_diff_exp_file = 
      ActionDispatch::Http::UploadedFile.new({:tempfile=>transcript_diff_exp_file})
    uploaded_gene_diff_exp_file = 
      ActionDispatch::Http::UploadedFile.new({:tempfile=>gene_diff_exp_file})
    uploaded_transcript_isoform_file = 
      ActionDispatch::Http::UploadedFile.new({:tempfile=>transcript_isoform_file})
    #Create and fill in the class
    @it = Upload_Cuffdiff.new(FactoryGirl.create(:user))
    @it.set_attributes_and_defaults()
    @it.dataset_name = 'Test Dataset'
    @it.has_diff_exp = true
    @it.has_transcript_isoforms = true
    @it.transcripts_fasta_file = uploaded_fasta_file
    @it.transcript_diff_exp_file = uploaded_transcript_diff_exp_file
    @it.gene_diff_exp_file = uploaded_gene_diff_exp_file 
    @it.transcript_isoforms_file = uploaded_transcript_isoform_file
    @it.save!
  end
  
  it 'should have all genes have transcripts' do
    @it.ds.genes.each do |gene|
      gene.transcripts.count.should_not eq(0)
    end
  end
  
  it 'should save without errors if valid'
  
  it 'should do something with the logger'
  
  it 'should delete the blast database on rollback if it was created'
  
  it 'should work for 4 samples'
  
  it 'should be transactional, writing either all the data or none at all'
  
#   it 'should link the dataset to the user' do
#     Dataset.first.user.id.should eq(User.first.id)
#   end
#   
#   it 'should add 0 users to the database' do
#     User.count.should eq(1)
#   end
#   
#   it 'should add 1 dataset to the database' do
#     Dataset.count.should eq(1)
#   end
#   
#   it 'should add 10 transcripts to the database' do
#     Transcript.count.should eq(10)
#   end
#   
#   it 'should add 10 genes to the database' do
#     Gene.count.should eq(10)
#   end
#   
#   it 'should add 10 sets of transcript fpkm tracking information to the database' do
#     TranscriptFpkmTrackingInformation.count.should eq(10)
#   end
#   
#   it 'should add 20 fpkm samples to the database' do
#     FpkmSample.count.should eq(20)
#   end
#   
#   it 'should add 2 samples to the database' do
#     Sample.count.should eq(2)
#   end
#   
#   it 'should add 1 sample comparison to the database' do
#     SampleComparison.count.should eq(1)
#   end
#   
#   it 'should add 20 differential expression tests to the database' do
#     DifferentialExpressionTest.count.should eq(20)
#   end
#   
#   it 'should add 55 go terms to the database' do
#     GoTerm.count.should eq(55)
#   end
#   
#   it 'should add 76 transcript has go terms to the database' do
#     TranscriptHasGoTerm.count.should eq(76)
#   end
  
  it 'should delete the uploaded files when done' do
    File.exists?(@it.transcripts_fasta_file.tempfile.path).should be_false
    File.exists?(@it.transcript_diff_exp_file.tempfile.path).should be_false
    File.exists?(@it.gene_diff_exp_file.tempfile.path).should be_false
    File.exists?(@it.transcript_isoforms_file.tempfile.path).should be_false
  end
end
