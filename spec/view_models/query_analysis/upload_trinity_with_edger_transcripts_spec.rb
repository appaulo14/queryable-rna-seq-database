require 'spec_helper'
require 'view_models/shared_examples.rb'

describe UploadTrinityWithEdgeRTranscripts do
  before(:all) do
    DatabaseCleaner.clean
  end
  
  before(:each) do
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
    @test_files_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                       "test_files/cuffdiff"
    UploadUtil.stub(:generate_go_terms){"#{@test_files_path}/3_samples/go_terms.annot"}
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean
  end
  
  ################# Validations ###################
  describe 'validations', :type => :validations do
    before(:each) do
      @it = FactoryGirl.build(:upload_trinity_with_edger_transcripts_with_2_samples)
    end
    
    describe 'transcripts_fasta_file' do
      before(:each) do @attribute = 'transcripts_fasta_file' end
      
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
  
  ################# White Box ###################
  describe 'flow control', :type => :white_box do
    
  end
  
  ################# Black Box ###################
  describe 'database/email/file interaction', :type => :black_box do
    describe 'for 2 samples' do
      before(:each) do
        @it = FactoryGirl.build(:upload_trinity_with_edger_transcripts_with_2_samples)
      end
      
      it 'should add 6 transcripts to the database' do
        lambda do
          @it.save
        end.should change(Transcript,:count).by(6)
      end
      it 'should add 0 genes to the database' do
        lambda do
          @it.save
        end.should change(Gene,:count).by(0)
      end
      it 'should add 0 fpkm samples to the database' do
        lambda do
          @it.save
        end.should change(FpkmSample,:count).by(0)
      end
      it 'should add 2 samples to the database' do
        lambda do
          @it.save
        end.should change(Sample,:count).by(2)
      end
      it 'should add 1 sample comparisons to the database' do
        lambda do
          @it.save
        end.should change(SampleComparison,:count).by(1)
      end
      it 'should add 6 differential expression tests to the database' do
        lambda do
          @it.save
        end.should change(DifferentialExpressionTest,:count).by(6)
      end
      it 'should have no differential expression tests with null fpkms' do
        @it.save
        DifferentialExpressionTest.all.each do |det|
          det.sample_1_fpkm.should_not be_nil
          det.sample_2_fpkm.should_not be_nil
        end
      end
      it 'should add 250 transcript has go terms to the database' 
#       do
#         lambda do
#           @it.save
#         end.should change(TranscriptHasGoTerm,:count).by(250)
#       end
      it 'should add 24 transcript fpkm tracking informations to the database' 
#       do
#         lambda do
#           @it.save
#         end.should change(TranscriptFpkmTrackingInformation,:count).by(24)
#       end
      it 'should add 88 go terms to the database'
#       do
#         lambda do
#           @it.save
#         end.should change(GoTerm,:count).by(88)
#       end
      it 'should add 0 go terms to the database if they already exist in the database'
#       do
#         @it.save
#         lambda do
#           FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
#         end.should change(GoTerm,:count).by(0)
#       end
      
      it_should_behave_like 'any upload view model when no exception occurs'
      it_should_behave_like 'any upload view model when an exception occurs' 
    end
    
    describe 'for 3 samples' do
      before(:each) do
        @it = FactoryGirl.build(:upload_trinity_with_edger_transcripts_with_3_samples)
      end
      
      it 'should add 6 transcripts to the database' do
        lambda do
          @it.save
        end.should change(Transcript,:count).by(6)
      end
      it 'should add 0 genes to the database' do
        lambda do
          @it.save
        end.should change(Gene,:count).by(0)
      end
      it 'should add 0 fpkm samples to the database' do
        lambda do
          @it.save
        end.should change(FpkmSample,:count).by(0)
      end
      it 'should add 3 samples to the database' do
        lambda do
          @it.save
        end.should change(Sample,:count).by(3)
      end
      it 'should add 3 sample comparisons to the database' do
        lambda do
          @it.save
        end.should change(SampleComparison,:count).by(3)
      end
      it 'should add 18 differential expression tests to the database' do
        lambda do
          @it.save
        end.should change(DifferentialExpressionTest,:count).by(18)
      end
      it 'should have no differential expression tests with null fpkms' do
        @it.save
        DifferentialExpressionTest.all.each do |det|
          det.sample_1_fpkm.should_not be_nil
          det.sample_2_fpkm.should_not be_nil
        end
      end
      it 'should add 250 transcript has go terms to the database' 
#       do
#         lambda do
#           @it.save
#         end.should change(TranscriptHasGoTerm,:count).by(250)
#       end
      it 'should add 24 transcript fpkm tracking informations to the database' 
#       do
#         lambda do
#           @it.save
#         end.should change(TranscriptFpkmTrackingInformation,:count).by(24)
#       end
      it 'should add 88 go terms to the database'
#       do
#         lambda do
#           @it.save
#         end.should change(GoTerm,:count).by(88)
#       end
      it 'should add 0 go terms to the database if they already exist in the database'
#       do
#         @it.save
#         lambda do
#           FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
#         end.should change(GoTerm,:count).by(0)
#       end
    
      it_should_behave_like 'any upload view model when no exception occurs'
      it_should_behave_like 'any upload view model when an exception occurs'  
    end
    
    describe 'for 4 samples' do
      before(:each) do
        @it = FactoryGirl.build(:upload_trinity_with_edger_transcripts_with_4_samples)
      end
    
      it 'should add 6 transcripts to the database' do
        lambda do
          @it.save
        end.should change(Transcript,:count).by(6)
      end
      it 'should add 0 genes to the database' do
        lambda do
          @it.save
        end.should change(Gene,:count).by(0)
      end
      it 'should add 0 fpkm samples to the database' do
        lambda do
          @it.save
        end.should change(FpkmSample,:count).by(0)
      end
      it 'should add 4 samples to the database' do
        lambda do
          @it.save
        end.should change(Sample,:count).by(4)
      end
      it 'should add 6 sample comparisons to the database' do
        lambda do
          @it.save
        end.should change(SampleComparison,:count).by(6)
      end
      it 'should add 36 differential expression tests to the database' do
        lambda do
          @it.save
        end.should change(DifferentialExpressionTest,:count).by(36)
      end
      it 'should have no differential expression tests with null fpkms' do
        @it.save
        DifferentialExpressionTest.all.each do |det|
          det.sample_1_fpkm.should_not be_nil
          det.sample_2_fpkm.should_not be_nil
        end
      end
      it 'should add 250 transcript has go terms to the database' 
#       do
#         lambda do
#           @it.save
#         end.should change(TranscriptHasGoTerm,:count).by(250)
#       end
      it 'should add 24 transcript fpkm tracking informations to the database' 
#       do
#         lambda do
#           @it.save
#         end.should change(TranscriptFpkmTrackingInformation,:count).by(24)
#       end
      it 'should add 88 go terms to the database'
#       do
#         lambda do
#           @it.save
#         end.should change(GoTerm,:count).by(88)
#       end
      it 'should add 0 go terms to the database if they already exist in the database'
#       do
#         @it.save
#         lambda do
#           FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
#         end.should change(GoTerm,:count).by(0)
#       end
      
      it_should_behave_like 'any upload view model when no exception occurs'
      it_should_behave_like 'any upload view model when an exception occurs' 
    end
  end
end
