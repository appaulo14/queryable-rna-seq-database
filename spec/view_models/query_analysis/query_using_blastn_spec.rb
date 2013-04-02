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
    @it.set_attributes_and_defaults({:text_area_fastas => "AAAA"})
  end
  
  ################# Validations ###################
  describe 'validations', :type => :validations do
    describe 'dataset_id' do
      before(:each) do @attribute = 'dataset_id' end
    
      it_should_behave_like 'a required attribute'
    end
    
    describe 'text_area_fastas' do
      before(:each) do @attribute = 'text_area_fastas' end
      
      describe 'when query_input_method == "text_area"' do
        before(:each) do 
          @it.query_input_method = 'text_area'
          @it.set_attributes_and_defaults({:text_area_fastas => "AAAA"})
        end
        
        it_should_behave_like 'a string containing nucleotide fasta sequences'
        it_should_behave_like 'a required attribute'
      end

      describe 'when query_input_method == "file"' do
        before(:each) do 
          @it.query_input_method = 'file'
          @it.fasta_file = generate_uploaded_file('AAAA')
        end
        
        it_should_behave_like 'an optional attribute'
      end
    end
    
    describe 'fasta_file' do
      before(:each) do @attribute = 'fasta_file' end
      
      describe 'when query_input_method == "file"' do
        before (:each) do
          @it.query_input_method = 'file'
          @it.fasta_file = generate_uploaded_file('AAAA')
        end
        
        it_should_behave_like 'an uploaded file'
        it_should_behave_like 'a required attribute'
      end
      
      describe 'when query_input_method == "text_area"' do
        before (:each) do
          @it.query_input_method = 'text_area'
          @it.set_attributes_and_defaults({:text_area_fastas => "AAAA"})
        end
        
        it_should_behave_like 'an optional attribute'
      end
    end
    
    describe 'num_alignments' do
      before(:each) do @attribute = 'num_alignments' end
      
      it 'should be valid for the available num alignments' do
        @it.available_num_alignments.each do |num_alignments|
          @it.set_attributes_and_defaults({:num_alignments => num_alignments})
          @it.should be_valid
        end
      end
      it 'should not be valid for non-approved num alignments' do
        [-42, 45.3, "kittens"].each do |bad_num_alignments|
          @it.set_attributes_and_defaults({:num_alignments => bad_num_alignments})
          @it.should_not be_valid
        end
      end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'evalue' do
      before(:each) do @attribute = 'evalue' end
    
      it_should_behave_like 'a number'
      it_should_behave_like 'a required attribute'
    end
    
    describe 'query_input_method' do
      before(:each) do 
        @attribute = 'query_input_method'
        @it.text_area_fastas= 'AAAA'
        @it.fasta_file = generate_uploaded_file('AAAA')
      end
      
      it 'should be valid for "text_area"' do
        @it.query_input_method = 'text_area'
        @it.should be_valid
      end
      it 'should be valid for "file"' do
        @it.query_input_method = 'file'
        @it.should be_valid
      end
      
      it 'should not valid for other non-approved values' do
        [1,'cats'].each do |invalid_query_input_method|
          @it.query_input_method = invalid_query_input_method
          @it.should_not be_valid
        end
      end
    
      it_should_behave_like 'a required attribute'
    end
    
    describe 'use_soft_masking' do
      before(:each) do @attribute = 'use_soft_masking' end
      
      it_should_behave_like 'a view model-style boolean'
      it_should_behave_like 'a required attribute'
    end
    
    describe 'filter_low_complexity_regions' do
      before(:each) do @attribute = 'filter_low_complexity_regions' end
      
      it_should_behave_like 'a view model-style boolean'
      it_should_behave_like 'a required attribute'
    end
    
    describe 'use_lowercase_masking' do
      before(:each) do @attribute = 'use_lowercase_masking' end
    
      it_should_behave_like 'a view model-style boolean'
      it_should_behave_like 'a required attribute'
    end
    
    describe 'word_size' do
      before(:each) do @attribute = 'word_size' end
      
      it 'should be valid for all the available word sizes' do
        @it.available_word_sizes.each do |word_size|
          @it.set_attributes_and_defaults({:word_size => word_size})
          @it.should be_valid
        end
      end
      
      it 'should not be valid for non-approved word sizes' do
        [100,42, "kittens"].each do |bad_word_size|
          @it.set_attributes_and_defaults({:word_size => bad_word_size})
          @it.should_not be_valid
        end
      end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'gap_costs' do
      before(:each) do @attribute = 'gap_costs' end
    
      it_should_behave_like 'a required attribute'
    end
    
    it 'should be valid for the available match/mismatch scores and their gap costs' do
      @it.available_match_and_mismatch_scores.each do |m_ms_score|
        @it.set_attributes_and_defaults({:match_and_mismatch_scores => m_ms_score})
        @it.available_gap_costs.each do |gap_costs|
          @it.gap_costs = gap_costs
          @it.should be_valid
        end
      end
    end
    
    it 'should not be valid for gap costs that are ' do
      @it.available_match_and_mismatch_scores.each do |m_ms_score|
        @it.set_attributes_and_defaults({:match_and_mismatch_scores => m_ms_score})
        available_gap_costs = @it.available_gap_costs
        @it.available_match_and_mismatch_scores.each do |m_ms_score2|
          @it.set_attributes_and_defaults({:match_and_mismatch_scores => m_ms_score})
          (available_gap_costs - @it.available_gap_costs).each do |gap_costs|
            @it.gap_costs = gap_costs
            @it.should_not be_valid
          end
        end
      end
    end
    
    describe 'match_and_mismatch_scores' do
      before(:each) do @attribute = 'match_and_mismatch_scores' end
    
      it_should_behave_like 'a required attribute'
    end
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
    
    describe 'dataset_id' do
      it 'should put the blast database location in the command string' do
        ds = Dataset.find(@it.dataset_id)
        SystemUtil.should_receive('system!').with(/-db #{ds.blast_db_location}/)
        @it.blast
      end
    end
    
#    describe 'fasta_sequence' do
#    end
#    
#    describe 'fasta_file' do
#    end
    
    describe 'num_alignments' do
      it 'should put the correct num alignments in the command string' do
        @it.available_num_alignments.each do |num_alignments|
          @it.num_alignments = num_alignments
          expected_regex = /-num_alignments #{num_alignments}/
          SystemUtil.should_receive('system!').with(expected_regex)
          @it.blast
        end
      end
    end
    
    describe 'evalue' do
      it 'should put the e value in the command string' do
        evalue = @it.evalue.to_f + 5.0
        @it.evalue = evalue
        expected_regex = /-evalue #{evalue}/
        SystemUtil.should_receive('system!').with(expected_regex)
        @it.blast
      end
    end
    
    describe 'query_input_method' do
      it 'should create two tempfiles when using a text area' do
        params = {:query_input_method => 'text_area',
                  :text_area_fastas => 'AAAA'}
        @it.set_attributes_and_defaults(params)
        Tempfile.should_receive(:new).twice.and_call_original
        @it.blast
      end
      
      it 'should create one tempfile when using a fasta file' do
        uploaded_file = generate_uploaded_file("AAAA")
        params = {:query_input_method => 'file',
                  :fasta_file => uploaded_file}
        @it.set_attributes_and_defaults(params)
        Tempfile.should_receive(:new).once.and_call_original
        @it.blast
      end
    end
    
    describe 'use_soft_masking' do
      it 'should put "-soft_masking true" in the command string when true' do
        @it.use_soft_masking = '1'
        SystemUtil.should_receive('system!').with(/-soft_masking true/)
        @it.blast
      end
      
      it 'should put "-soft_masking false" in the command string when false' do
        @it.use_soft_masking = '0'
        SystemUtil.should_receive('system!').with(/-soft_masking false/)
        @it.blast
      end
    end
    
    describe 'filter_low_complexity_regions' do
      it 'when true should put "-lcase_masking" in the command string' do
        @it.filter_low_complexity_regions = '1'
        SystemUtil.should_receive('system!').with(/-dust 'yes'/)
        @it.blast
      end
      
      it 'when false should not put "-lcase_masking" in the command string' do
        @it.filter_low_complexity_regions = '0'
        SystemUtil.should_receive('system!').with(/-dust 'no'/)
        @it.blast
      end
    end
    
    describe 'use_lowercase_masking' do
      it 'when true should put "-lcase_masking" in the command string' do
        @it.use_lowercase_masking = '1'
        SystemUtil.should_receive('system!').with(/-lcase_masking/)
        @it.blast
      end
      
      it 'when false should not put "-lcase_masking" in the command string' do
        @it.use_lowercase_masking = '0'
        SystemUtil.should_not_receive('system!').with(/-lcase_masking/)
        @it.blast
      end
    end
    
    describe 'word_size' do 
      it 'should put the correct word size in the command string' do
        @it.available_word_sizes.each do |word_size|
          @it.word_size = word_size
          expected_regex = /-word_size #{word_size}/
          SystemUtil.should_receive('system!').with(expected_regex)
          @it.blast
        end
      end
    end
    
    describe 'gap_costs' do
      it 'should put the correct gap costs in the command string' do
        @it.available_match_and_mismatch_scores.each do |m_ms_score|
          @it.set_attributes_and_defaults({:match_and_mismatch_scores => m_ms_score})
          @it.available_gap_costs.each do |gap_costs|
            @it.gap_costs = gap_costs
            if gap_costs.downcase == "linear"
              expected_gapopen = '0'
              expected_gapextend = '0'
            else
              gap_costs_regex = /\AExistence:\s+(\d+),\s*Extension:\s+(\d+)\z/
              (expected_gapopen, expected_gapextend) = 
                  gap_costs.match(gap_costs_regex).captures
            end
            expected_regex = 
                /-gapopen #{expected_gapopen} -gapextend #{expected_gapextend}/
            SystemUtil.should_receive('system!').with(expected_regex)
            @it.blast
          end
        end
      end
    end
    
    describe 'match_and_mismatch_scores' do
      it 'should put match/mismatch scores in the command string' do
        @it.available_match_and_mismatch_scores.each do |m_ms_score|
          @it.set_attributes_and_defaults({:match_and_mismatch_scores => m_ms_score})
          @it.available_gap_costs.each do |gap_costs|
            @it.gap_costs = gap_costs
            expected_match = m_ms_score.split(',')[0]
            expected_mismatch = m_ms_score.split(',')[1] 
            expected_regex = /-reward #{expected_match} -penalty #{expected_mismatch}/
            SystemUtil.should_receive('system!').with(expected_regex)
            @it.blast
          end
        end
      end
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
    
    describe 'text_area_fastas' do
      before (:each) do @attribute = 'text_area_fastas' end
      
      it 'should have the correct query length' do
        fasta_sequence = @it.text_area_fastas.to_s + "AAAA"
        expected_query_len = text_area_fastas.length
        params = {:query_input_method => 'text_area',
                  :text_area_fastas => fasta_sequence, 
                  :fasta_file => nil}
        @it.set_attributes_and_defaults(params)
        blast_report = @it.blast
        blast_report.query_len.should eq(expected_query_len)
      end
      
      it_should_behave_like 'an attribute without a default value'
    end
    
    describe 'fasta_file' do
      before (:each) do @attribute = 'fasta_file' end
      
      it 'should have the correct query length' do
        fasta_sequence = @it.text_area_fastas.to_s + "AAAA"
        expected_query_len = fasta_sequence.length
        uploaded_file = generate_uploaded_file(fasta_sequence)
        params = {:query_input_method => 'file',
                  :fasta_file => uploaded_file, 
                  :text_area_fastas => nil}
        @it.set_attributes_and_defaults(params)
        blast_report = @it.blast
        blast_report.query_len.should eq(expected_query_len)
      end
      
      it_should_behave_like 'an attribute without a default value'
    end
    
    describe 'num_alignments' do
      before (:each) do @attribute = 'num_alignments' end
      
      it_should_behave_like 'an attribute with a default value'
    end
    
    describe 'evalue' do
      before (:each) do @attribute = 'evalue' end
      
      it 'should correctly appear in the blast report' do
        expected_evalue = @it.evalue + 1
        @it.evalue = expected_evalue
        blast_report = @it.blast
        blast_report.expect.should eq(expected_evalue)
      end
    
      it_should_behave_like 'an attribute with a default value'
    end
    
    describe 'use_soft_masking' do
      before (:each) do @attribute = 'use_soft_masking' end
      
      it 'when "1" the report should list it as one of the filtering options' do
        @it.set_attributes_and_defaults({:use_soft_masking => '1'})
        blast_report = @it.blast.filter.should match(/m/)
      end
      
      it 'when"0" the report should not list it as one of the filtering options' do
        @it.set_attributes_and_defaults({:use_soft_masking => '0'})
        blast_report = @it.blast
        blast_report.filter.should_not match(/m/)
      end
      
      it_should_behave_like 'an attribute with a default value'
    end
    
    describe 'filter_low_complexity_regions' do
      before (:each) do @attribute = 'filter_low_complexity_regions' end
      
      it 'when "1" the report should list it as one of the filtering options' do
        @it.set_attributes_and_defaults({:filter_low_complexity_regions => '1'})
        blast_report = @it.blast
        blast_report.filter.should match(/L/)
      end
      
      it 'when"0" the report should not list it as one of the filtering options' do
        @it.set_attributes_and_defaults({:filter_low_complexity_regions => '0'})
        blast_report = @it.blast
        blast_report.filter.should_not match(/L/)
      end
      
      it_should_behave_like 'an attribute with a default value'
    end
    
    describe 'use_lowercase_masking' do
      before (:each) do @attribute = 'use_lowercase_masking' end
      
      #Isn't in the filter parameter so can't be checked in the report
      
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
