require 'spec_helper'

describe FindGoTermsForDataset do
  before(:all) do
    @test_files_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                       "test_files/cuffdiff"
    DatabaseCleaner.clean
    
  end
  
  before(:each) do
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
    FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
    GoTermFinderAndProcessor
        .any_instance
        .stub(:run_blast2go)
        .and_return("#{@test_files_path}/go_terms.annot")
    GoTermFinderAndProcessor.any_instance.stub(:cleanup_files)
    @it = FindGoTermsForDataset.new(User.first)
    @it.set_attributes_and_defaults()
  end
  
  describe 'when successful' do
    before (:each) do
      GoTermFinderAndProcessor.any_instance.stub(:run_blastx)
    end
    
    it 'should add 30 transcript-go term associations' do
      lambda do 
        @it.find_and_save()
      end.should change(TranscriptHasGoTerm,:count).by(30)
    end
    it 'should have dataset.go_terms_status set to "found"' do
      @it.find_and_save()
      Dataset.find(@it.dataset_id).go_terms_status.should eq('found')
    end
  end
  
  describe 'when failed' do
    before(:each) do
      GoTermFinderAndProcessor.any_instance.stub(:run_blastx){raise SeededTestException}
    end
    
    it 'should not add any transcript-go term associations when failed' do
      lambda do 
        begin
          @it.find_and_save()
        rescue SeededTestException => ex
        end
      end.should change(TranscriptHasGoTerm,:count).by(0)
    end
    it 'should have dataset.go_terms_status set to "not-started" when failed' do
      begin
        @it.find_and_save()
      rescue SeededTestException => ex
      end
      Dataset.find(@it.dataset_id).go_terms_status.should eq('not-started')
    end
  end
end
