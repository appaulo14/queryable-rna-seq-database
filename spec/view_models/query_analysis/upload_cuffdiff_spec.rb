require 'spec_helper'

describe Upload_Cuffdiff do
  before(:each) do 
    #Change to the directory of this spec
    Dir.chdir("#{Rails.root}/spec/view_models/query_analysis")
    #Make copies of the test files
    FileUtils.copy('transcripts.fasta','cuffdiff_fasta_file')
    FileUtils.copy('isoform_exp.diff','transcript_diff_exp_file')
    FileUtils.copy('gene_exp.diff', 'gene_diff_exp_file')
    FileUtils.copy('isoforms.fpkm_tracking','transcript_isoform_file')
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
    @it.has_diff_exp = true
    @it.has_transcript_isoforms = true
    @it.transcripts_fasta_file = uploaded_fasta_file
    @it.transcript_diff_exp_file = uploaded_transcript_diff_exp_file
    @it.gene_diff_exp_file = uploaded_gene_diff_exp_file 
    @it.transcript_isoforms_file = uploaded_transcript_isoform_file
  end
  
  it 'should save with errors if valid' do
    @it.save!
  end
  
  it 'should work for 4 samples'
  
  it 'should be transactional, writing either all the data or none at all'
  
  it 'should link the dataset to the user'
  
  it 'should add 0 users to the database'
  
  it 'should add 1 dataset to the database'
  
  it 'should add 406 transcripts to the database'
  
  it 'should add 170 genes to the database'
  
  it 'should add 406 sets of transcript fpkm tracking information to the database'
  
  it 'should add 812 fpkm samples to the database'
  
  it 'should add 2 samples to the database'
  
  it 'should add 1 sample comparison to the database'
  
  it 'should add 576 differential expression tests to the database'
  
  it 'should add X go terms to the database'
  
  it 'should add X transcript has go terms to the database'
  
  after(:each) do
    #Delete the temporary upload files
    File.delete(@it.transcripts_fasta_file.tempfile.path)
    File.delete(@it.transcript_diff_exp_file.tempfile.path)
    File.delete(@it.gene_diff_exp_file.tempfile.path)
    File.delete(@it.transcript_isoforms_file.tempfile.path)
  end
end
