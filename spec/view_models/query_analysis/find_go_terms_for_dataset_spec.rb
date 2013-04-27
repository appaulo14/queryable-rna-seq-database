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
  end
  
  it 'shoul goat' do
    FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
    GoTermFinderAndProcessor
        .any_instance
        .stub(:run_blast2go)
        .and_return("#{@test_files_path}/go_terms.annot")
    GoTermFinderAndProcessor.any_instance.stub(:run_blastx)
    @it = FindGoTermsForDataset.new(User.first)
    @it.set_attributes_and_defaults()
    lambda do 
      @it.find_and_save()
    end.should change(Transcript,:count).by(24)
  end
end
