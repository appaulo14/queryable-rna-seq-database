require 'spec_helper'
require 'view_models/shared_examples.rb'

describe UploadTrinityWithEdgeRTranscripts do
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
    describe 'transcripts_fasta_file' do
      before(:each) do @attribute = 'transcripts_fasta_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'transcript_diff_exp_files' do
      before(:each) do @attribute = 'transcript_diff_exp_files' end
      
      it 'should behave like an array of uploaded files'
      
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
  
  ################# White Box ###################
  describe 'flow control', :type => :white_box do
  end
  
  ################# Black Box ###################
  describe 'database/email/file interaction', :type => :black_box do
    describe 'for 2 samples' do
      before(:each) do
        @it = FactoryGirl.build(:upload_trinity_with_edger_transcripts_with_2_samples)
      end
    
      it_should_behave_like 'any upload view model when an exception occurs' 
    end
    
    describe 'for 3 samples' do
      before(:each) do
        @it = FactoryGirl.build(:upload_trinity_with_edger_transcripts_with_3_samples)
      end
    
      it_should_behave_like 'any upload view model when an exception occurs' 
    end
    
    describe 'for 4 samples' do
      before(:each) do
        @it = FactoryGirl.build(:upload_trinity_with_edger_transcripts_with_4_samples)
      end
    
      it_should_behave_like 'any upload view model when an exception occurs' 
    end
  end
end
