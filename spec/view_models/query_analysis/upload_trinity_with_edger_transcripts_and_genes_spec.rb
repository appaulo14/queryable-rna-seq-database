require 'spec_helper'
require 'view_models/shared_examples.rb'

describe UploadTrinityWithEdgeRTranscriptsAndGenes do
  before(:all) do
    DatabaseCleaner.clean
  end
  
  before(:each) do
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean
  end
  
  ################# Validations ###################
  describe 'validations', :type => :validations do
    before(:each) do
      @it = FactoryGirl.build(:upload_trinity_with_edger_transcripts_and_genes_with_2_samples)
    end
    
    it 'should be valid when all field are valid' do
      @it.should be_valid
    end
    
    it 'should not be valid if the transcript_diff_exp_files and ' +
       'gene_diff_exp_files are different lengths' do
      uploaded_files = []
      uploaded_files << to_cuffdiff_uploaded_file(2,'transcripts.fasta')
      uploaded_files << to_cuffdiff_uploaded_file(2,'transcripts.fasta')
      @it.gene_diff_exp_files = uploaded_files
      @it.transcript_diff_exp_files = uploaded_files[0..0]
      @it.should_not be_valid
    end
    
    describe 'transcripts_fasta_file' do
      before(:each) do @attribute = 'transcripts_fasta_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'gene_diff_exp_files' do
      before(:each) do @attribute = 'gene_diff_exp_files' end
      
      it_should_behave_like 'an array of uploaded files'
      it_should_behave_like 'a required attribute'
    end
    
    describe 'gene_fpkm_file' do
      before(:each) do @attribute = 'gene_fpkm_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'transcript_diff_exp_files' do
      before(:each) do @attribute = 'transcript_diff_exp_files' end
      
      it_should_behave_like 'an array of uploaded files'
      it_should_behave_like 'a required attribute'
    end
    
    describe 'transcript_fpkm_file' do
      before(:each) do @attribute = 'transcript_fpkm_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'dataset_name' do
      before(:each) do @attribute = 'dataset_name' end
      
      it_should_behave_like 'a required attribute'
    end
  end
end
