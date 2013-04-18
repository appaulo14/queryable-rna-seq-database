require 'spec_helper'

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
    it 'should query by the proper dataset'
    it 'should query by the proper sample comparison'
    it 'should query by the the proper p-value cutoff'
    it 'should query by the proper FDR cutoff'
    
    it 'should work for both cuffdiff and trinity with edgeR?'
    
    it 'should have the correct transcripts' do
      @it.query
      dataset = Dataset.find_by_id(@it.dataset_id)
      transcripts = dataset.transcripts
      (0..@it.results.count-1).each do |i|
        @it.results[i][:transcript_name].should eq(transcripts[i].name_from_program)  
      end
    end
    
    it 'should have the correct genes' do
      @it.query
      dataset = Dataset.find_by_id(@it.dataset_id)
      transcripts = dataset.transcripts
      (0..@it.results.count-1).each do |i|
        @it.results[i][:gene_name].should eq(transcripts[i].gene.name_from_program)  
      end
    end
    
    it 'should have the correct go terms' do
      @it.query
      dataset = Dataset.find_by_id(@it.dataset_id)
      transcripts = dataset.transcripts
      (0..@it.results.count-1).each do |i|
        expected_go_terms = transcripts[i].go_terms
        (0..@it.results[i][:go_terms].count-1).each do |ii|
          actual_go_term = @it.results[i][:go_terms][ii]
          expected_go_term = expected_go_terms[ii]
          actual_go_term.should eq(expected_go_term)
        end
      end
    end
    
    it 'should have the correct p-value' do
      @it.query
      dataset = Dataset.find_by_id(@it.dataset_id)
      transcripts = dataset.transcripts
      (0..@it.results.count-1).each do |i|
        dets = transcripts[i].differential_expression_tests 
        det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
        @it.results[i][:p_value].should eq(det.p_value)
      end
    end
    it 'should have the correct fdr' do
      @it.query
      dataset = Dataset.find_by_id(@it.dataset_id)
      transcripts = dataset.transcripts
      (0..@it.results.count-1).each do |i|
        dets = transcripts[i].differential_expression_tests 
        det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
        @it.results[i][:fdr].should eq(det.fdr)
      end
    end
    
    it 'should have the correct sample 1 fpkm' do
      @it.query
      dataset = Dataset.find_by_id(@it.dataset_id)
      transcripts = dataset.transcripts
      (0..@it.results.count-1).each do |i|
        dets = transcripts[i].differential_expression_tests 
        det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
        @it.results[i][:sample_1_fpkm].should eq(det.sample_1_fpkm)
      end
    end
    it 'should have the correct sample 2 fpkm' do
      @it.query
      dataset = Dataset.find_by_id(@it.dataset_id)
      transcripts = dataset.transcripts
      (0..@it.results.count-1).each do |i|
        dets = transcripts[i].differential_expression_tests 
        det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
        @it.results[i][:sample_2_fpkm].should eq(det.sample_2_fpkm)
      end
    end
    it 'should have the correct log fold change' do
      @it.query
      dataset = Dataset.find_by_id(@it.dataset_id)
      transcripts = dataset.transcripts
      (0..@it.results.count-1).each do |i|
        dets = transcripts[i].differential_expression_tests 
        det = dets.where(:sample_comparison_id => @it.sample_comparison_id)[0]
        @it.results[i][:log_fold_change].should eq(det.log_fold_change)
      end
    end
  end
end
