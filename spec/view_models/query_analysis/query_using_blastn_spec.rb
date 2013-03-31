require 'spec_helper'
require 'view_models/shared_examples.rb'

describe QueryUsingBlastn do
  

  it 'should do something when no datasets are available for the page, such as ' +
     'have a check_for_datasets method that returns true or false'
     
  it 'should return a Bio::Blast::Report object'
  
  ################# Validations ###################
  describe 'validations', :type => :validations do
    # Describe all the attributes
  end
  
  ################# White Box ###################
  describe 'flow control', :type => :white_box do
    
  end
  
  ################# Black Box ###################
  describe 'database/email/file interaction', :type => :black_box do
    before (:all) do
      DatabaseCleaner.clean
    end
  
    before (:each) do
      File.stub(:delete){}
      FactoryGirl.build(:upload_fasta_sequences).save
      @it = QueryUsingBlastn.new(User.first)
      @it.set_attributes_and_defaults()
    end
    
    describe 'dataset_id' do
      before (:each) do @attribute = 'dataset_id' end
      
      it "should use the dataset's blast database" do
        dataset = Dataset.find_by_id(@it.dataset_id)
        blast_report = @it.blast
        blast_report.db.should eq(dataset.blast_db_location)
      end
    
      it_should_behave_like 'an attribute with a default value'
    end
    
    describe 'fasta_sequence' do
      before (:each) do @attribute = 'fasta_sequence' end
      
      it_should_behave_like 'an attribute without a default value'
    end
    
    describe 'fasta_file' do
      before (:each) do @attribute = 'fasta_file' end
      
      it_should_behave_like 'an attribute without a default value'
    end
    
    describe 'num_alignments' do
      before (:each) do @attribute = 'num_alignments' end
      
      it_should_behave_like 'an attribute with a default value'
    end
    
    describe 'word_size' do
      before (:each) do @attribute = 'word_size' end
    
      it_should_behave_like 'an attribute with a default value'
    end
    #Analyze the Bio::Blast::Report object
  end
end
