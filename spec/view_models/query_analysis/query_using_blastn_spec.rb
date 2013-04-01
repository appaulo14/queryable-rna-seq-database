require 'spec_helper'
require 'view_models/shared_examples.rb'

describe QueryUsingBlastn do
  before (:all) do
    DatabaseCleaner.clean
  end

  before (:each) do
    File.stub(:delete){}
    FactoryGirl.build(:upload_fasta_sequences).save
    @it = QueryUsingBlastn.new(User.first)
    @it.set_attributes_and_defaults({:fasta_sequence => "AAAA"})
  end

  it 'should do something when no datasets are available for the page, such as ' +
     'have a check_for_datasets method that returns true or false'
     
  it 'should return a Bio::Blast::Report object'
  
  ################# Validations ###################
  describe 'validations', :type => :validations do
    # Describe all the attributes
  end
  
  ################# White Box ###################
  describe 'flow control', :type => :white_box do
    it 'should blast when valid' do
      @it.should_receive('valid?').ordered.and_return(true)
      @it.should_receive(:prepare_IO_files).ordered
      @it.should_receive(:generate_execution_string).ordered
      SystemUtil.should_receive('system!').ordered
      @it.should_receive('generate_blast_report_from_xml_results').ordered
      @it.should_receive('cleanup_files').ordered
      @it.blast
    end
    
    it 'should not blast when not valid' do
      @it.should_receive('valid?').ordered.and_return(false)
      @it.should_not_receive(:prepare_IO_files).ordered
      @it.should_not_receive(:generate_execution_string).ordered
      SystemUtil.should_not_receive('system!').ordered
      @it.should_not_receive('generate_blast_report_from_xml_results').ordered
      @it.should_not_receive('cleanup_files').ordered
      @it.blast
    end
  end
  
  ################# Black Box ###################
  describe 'database/email/file interaction', :type => :black_box do
    
    
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
    
    it 'should use the correct gap costs and match/mismatch scores' do
      @it.available_match_and_mismatch_scores.each do |m_ms_score|
        @it.set_attributes_and_defaults({:match_and_mismatch_scores => m_ms_score})
        @it.available_gap_costs.each do |gap_costs|
          @it.gap_costs = gap_costs
          blast_report = @it.blast()
          if gap_costs.downcase == "linear"
            blast_report.gap_open.should eq(0)
            blast_report.gap_extend.should eq(0)
          else
            gap_costs_regex = /\AExistence:\s+(\d+),\s*Extension:\s+(\d+)\z/
            (expected_gap_open, expected_gap_extend) = 
                gap_costs.match(gap_costs_regex).captures
            blast_report.gap_open.to_s.should eq(expected_gap_open)
            blast_report.gap_extend.to_s.should eq(expected_gap_extend)
          end
          blast_report.sc_match.to_s.should eq(m_ms_score.split(',')[0])
          blast_report.sc_mismatch.to_s.should eq(m_ms_score.split(',')[1])
        end
      end
    end
    #Analyze the Bio::Blast::Report object
  end
end
