require 'spec_helper'
require 'view_models/shared_examples.rb'

describe UploadFastaSequences do
   before(:all) do
    @test_files_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                       "test_files/cuffdiff"
    DatabaseCleaner.clean
  end
  
  before(:each) do
    @it = FactoryGirl.build(:upload_fasta_sequenes)
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
  end
  
  after(:all) do
    DatabaseCleaner.clean
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean
    #system("rm #{Rails.root}/db/blast_databases/test/*")
  end
  
  
  ################# Validations ###################
  describe 'validations', :type => :validations do
    describe 'transcripts_fasta_file' do
      before (:each) do @attribute = 'transcripts_fasta_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'dataset_name' do
      before (:each) do @attribute = 'dataset_name' end
      
      it_should_behave_like 'a required attribute'
    end
  end
  
  ################# White Box ###################
  describe 'flow control', :type => :white_box do
    before (:each) do
      @it.stub(:process_args_to_create_dataset)
      File.stub(:delete)
      UploadUtil.stub(:create_blast_database)
      UploadUtil.stub(:rollback_blast_database)
      QueryAnalysisMailer.stub(:notify_user_of_upload_success)
      QueryAnalysisMailer.stub(:notify_user_of_upload_failure)
    end
  
    describe 'when an exception occurs' do
      before (:each) do
        UploadUtil.stub(:create_blast_database){raise SeededTestException}
      end
      
      it 'should call QueryAnalysisMailer.notify_user_of_upload_failure' do
        begin
          QueryAnalysisMailer.should_receive(:notify_user_of_upload_failure)
          @it.save
        rescue SeededTestException => ex
        end
      end
      it 'should not call QueryAnalysisMailer.notify_user_of_upload_success' do
        begin 
          QueryAnalysisMailer.should_receive(:notify_user_of_upload_failure)
          @it.save 
        rescue SeededTestException => ex
        end
      end
      it 'should rollback the blast database' do
        begin
          UploadUtil.should_receive(:rollback_blast_database)
          @it.save
        rescue SeededTestException => ex
        end
      end
    end
    
    describe 'no matter whether an exception occurs' do
      it 'should call valid?' do
        @it.should_receive(:valid?)
        @it.save
      end
    
      it 'should delete transcripts_fasta_file' do
        transcripts_fasta_file_path = @it.transcripts_fasta_file.tempfile.path
        File.should_receive(:delete).with(transcripts_fasta_file_path)
        @it.save
      end
      
    end
    
    describe 'when no exception occurs' do
      it 'should call process_args_to_create_dataset' do
        @it.should_receive(:process_args_to_create_dataset)
        @it.save
      end
      it 'should call UploadUtil.create_blast_database' do
        UploadUtil.should_receive(:create_blast_database)
        @it.save
      end
      it 'should call QueryAnalysisMailer.notify_user_of_upload_success' do
        QueryAnalysisMailer.should_receive(:notify_user_of_upload_success)
        @it.save
      end
      it 'should not call QueryAnalysisMailer.notify_user_of_upload_failure' do
        QueryAnalysisMailer.should_not_receive(:notify_user_of_upload_failure)
        @it.save
      end
      it 'should not call UploadUtil.rollback_blast_database' do
        UploadUtil.should_not_receive(:rollback_blast_database)
        @it.save
      end
    end
  end
  
  ################# Black Box ###################
  describe 'database/email/file interaction', :type => :black_box do
    describe 'when an exception occurs' do
    end
    
    describe 'when no exception occurs' do
    end
  end
end
