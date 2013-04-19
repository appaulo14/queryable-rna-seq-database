require 'spec_helper'
require 'view_models/shared_examples.rb'

describe QueryDiffExpTranscripts do
  before (:all) do
    DatabaseCleaner.clean
    populate_short_list_of_go_terms()
    @go_annot_file_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                          "test_files/cuffdiff/go_terms.annot"
  end
  
  before (:each) do
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
    GoTermFinderAndProcessor.any_instance.stub(:run_blastx)
    GoTermFinderAndProcessor.any_instance.stub(:run_blast2go).and_return(@go_annot_file_path)
    FactoryGirl.build(
      :upload_cuffdiff_with_2_samples, :has_transcript_isoforms => '0'
    ).save
    @it = QueryDiffExpTranscripts.new(User.first)
    @it.set_attributes_and_defaults()
  end
  
  ################# Validations ###################
  describe 'validations', :type => :validations do
  end
  
  ################# White Box ###################
  describe 'flow control', :type => :white_box do
  end
  
  ################# Black Box ###################
  describe 'database/email/file interaction', :type => :black_box do
    describe 'attributes with default values' do
      describe 'dataset_id' do
        before (:each) do @attribute = 'dataset_id' end
        
        it_should_behave_like 'an attribute with a default value'
      end
      
      describe 'sample_comparison_id' do
        before (:each) do @attribute = 'sample_comparison_id' end
        
        it_should_behave_like 'an attribute with a default value'
      end
      
      describe 'fdr_or_p_value' do
        before (:each) do @attribute = 'fdr_or_p_value' end
        
        it_should_behave_like 'an attribute with a default value'
      end
      
      describe 'cutoff' do
        before (:each) do @attribute = 'cutoff' end
        
        it_should_behave_like 'an attribute with a default value'
      end
    end
    
    shared_examples_for 'a query that has the correct output data' do
      it 'should have the correct transcripts' do
        (0..@it.results.count-1).each do |i|
          @it.results[i][:transcript_name].should eq(@transcripts[i].name_from_program)  
        end
      end
      
      it 'should have the correct genes' do
        (0..@it.results.count-1).each do |i|
          @it.results[i][:gene_name].should eq(@transcripts[i].gene.name_from_program)  
        end
      end
      
      it 'should have the correct go terms' do
        (0..@it.results.count-1).each do |i|
          expected_go_terms = @transcripts[i].go_terms
          (0..@it.results[i][:go_terms].count-1).each do |ii|
            actual_go_term = @it.results[i][:go_terms][ii]
            expected_go_term = expected_go_terms[ii]
            actual_go_term.should eq(expected_go_term)
          end
        end
      end
      it 'should have the correct test statistic' do
        (0..@it.results.count-1).each do |i|
          dets = @transcripts[i].differential_expression_tests 
          det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
          @it.results[i][:test_statistic].should eq(det.test_statistic)
        end
      end
      it 'should have the correct p-value' do
        (0..@it.results.count-1).each do |i|
          dets = @transcripts[i].differential_expression_tests 
          det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
          @it.results[i][:p_value].should eq(det.p_value)
        end
      end
      it 'should have the correct fdr' do
        (0..@it.results.count-1).each do |i|
          dets = @transcripts[i].differential_expression_tests 
          det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
          @it.results[i][:fdr].should eq(det.fdr)
        end
      end
      it 'should have the correct sample 1 fpkm' do
        (0..@it.results.count-1).each do |i|
          dets = @transcripts[i].differential_expression_tests 
          det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
          @it.results[i][:sample_1_fpkm].should eq(det.sample_1_fpkm)
        end
      end
      it 'should have the correct sample 2 fpkm' do
        (0..@it.results.count-1).each do |i|
          dets = @transcripts[i].differential_expression_tests 
          det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
          @it.results[i][:sample_2_fpkm].should eq(det.sample_2_fpkm)
        end
      end
      it 'should have the correct log fold change' do
        (0..@it.results.count-1).each do |i|
          dets = @transcripts[i].differential_expression_tests 
          det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
          @it.results[i][:log_fold_change].should eq(det.log_fold_change)
        end
      end
      it 'should have the correct test status' do
        (0..@it.results.count-1).each do |i|
          dets = @transcripts[i].differential_expression_tests 
          det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
          @it.results[i][:test_status].should eq(det.test_status)
        end
      end
    end
    
    describe 'when the default settings' do
      before(:each) do
        @transcripts = Dataset.find_by_id(@it.dataset_id).transcripts
        @it.query()
      end
        
      it_should_behave_like 'a query that has the correct output data'
    end
    
    describe 'when the p-value is 1.0' do
      before(:each) do
        @it.fdr_or_p_value = 'p_value'
        @it.cutoff = '1.0'
        det_t = DifferentialExpressionTest.arel_table
        p_value_clause = det_t[:p_value].lteq(1.0)
        sample_cmp_clause = det_t[:sample_comparison_id].eq(@it.sample_comparison_id)
        where_clause = p_value_clause.and(sample_cmp_clause)
        dataset = Dataset.find_by_id(@it.dataset_id)
        @transcripts = dataset.transcripts
            .joins(:differential_expression_tests)
            .where(where_clause)
        @it.query()
      end
      
      it_should_behave_like 'a query that has the correct output data'
    end
    
    describe 'when using fdr at the default value' do
      before(:each) do
        @it.fdr_or_p_value = 'fdr'
        det_t = DifferentialExpressionTest.arel_table
        fdr_clause = det_t[:fdr].lteq(@it.cutoff.to_f)
        sample_cmp_clause = det_t[:sample_comparison_id].eq(@it.sample_comparison_id)
        where_clause = fdr_clause.and(sample_cmp_clause)
        dataset = Dataset.find_by_id(@it.dataset_id)
        @transcripts = dataset.transcripts
            .joins(:differential_expression_tests)
            .where(where_clause)
        @it.query()
      end
      
      it_should_behave_like 'a query that has the correct output data'
    end
    
    describe 'when the fdr is 1.0' do
      before(:each) do
        @it.fdr_or_p_value = 'fdr'
        @it.cutoff = '1.0'
        det_t = DifferentialExpressionTest.arel_table
        fdr_clause = det_t[:fdr].lteq(1.0)
        sample_cmp_clause = det_t[:sample_comparison_id].eq(@it.sample_comparison_id)
        where_clause = fdr_clause.and(sample_cmp_clause)
        dataset = Dataset.find_by_id(@it.dataset_id)
        @transcripts = dataset.transcripts
            .joins(:differential_expression_tests)
            .where(where_clause)
        @it.query()
      end
      
      it_should_behave_like 'a query that has the correct output data'
    end
    
    describe 'when filtering by go terms' do
      before(:each) do
        @it.go_terms = "transmembrane transporter activity;ribosomal"
        g_t = GoTerm.arel_table
        where_clause = g_t[:term].matches("%transmembrane transporter activity%")
        where_clause = where_clause.and(g_t[:term].matches("%ribosomal%"))
        @transcripts = []
        dataset = Dataset.find_by_id(@it.dataset_id)
        dataset.transcripts.each do |transcript|
          if not transcript.go_terms.where(where_clause).empty?
            @transcripts << transcript
          end
        end
        @it.query()
      end
      
      it_should_behave_like 'a query that has the correct output data'
    end
    
    describe 'when filtering by go ids' do
       before(:each) do
        @it.go_terms = "GO:0000005;GO:0000006;"
        g_t = GoTerm.arel_table
        where_clause = g_t[:id].eq("GO:0000005")
        where_clause = where_clause.and(g_t[:id].eq('GO:0000006'))
        @transcripts = []
        dataset = Dataset.find_by_id(@it.dataset_id)
        dataset.transcripts.each do |transcript|
          if not transcript.go_terms.where(where_clause).empty?
            @transcripts << transcript
          end
        end
        @it.query()
      end
      
      it_should_behave_like 'a query that has the correct output data'
    end
    
    describe 'when filterint by transcript name' do
      before(:each) do
        @it.transcript_name = "TCONS_0000026"
        @transcripts = Dataset.find_by_id(@it.dataset_id).transcripts
        t_t = Transcript.arel_table
        @transcripts = @transcripts.where(t_t[:name_from_program].matches("%TCONS_0000026%"))
        @it.query()
      end
        
      it_should_behave_like 'a query that has the correct output data'
    end
    
    describe 'when filtering by all filtering options' do
      before(:each) do
        @it.transcript_name = "TCONS_0000026"
        @it.go_terms = "regulation"
        @it.go_ids = "GO:0000001"
        g_t = GoTerm.arel_table
        where_clause = g_t[:id].eq("GO:0000001")
        where_clause = where_clause.and(g_t[:term].matches("%mitochondrion%"))
        dataset = Dataset.find_by_id(@it.dataset_id)
        @transcripts = dataset.transcripts.joins(:go_terms).where(where_clause)
        t_t = Transcript.arel_table
        @transcripts = @transcripts.where(t_t[:name_from_program].matches("%TCONS_0000026%"))
        @it.query()
      end
        
      it_should_behave_like 'a query that has the correct output data'
    end
    
    it 'should only have available datasets containing transcript diff exp data' do
      before_count = @it.names_and_ids_for_available_datasets.count
      FactoryGirl.create(:dataset, :has_transcript_diff_exp => false)
      @it.set_attributes_and_defaults()
      @it.names_and_ids_for_available_datasets.count.should eq(before_count)
    end
  end
end
