require 'spec_helper'
require 'controllers/shared_examples.rb'

describe QueryAnalysisController do
  describe 'upload_cuffdiff' do
    before (:each) do
      @action = 'upload_cuffdiff'
      @template = :upload_cuffdiff
      @view_model = UploadCuffdiff
      @process_data_method = :save
    end
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on POST'
    it_should_behave_like 'an action that processes data on POST'
  end
  
  describe 'upload_fasta_sequences' do
    before (:each) do
      @action = 'upload_fasta_sequences'
      @template = :upload_fasta_sequences
      @view_model = UploadFastaSequences
      @process_data_method = :save
    end
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on POST'
    it_should_behave_like 'an action that processes data on POST'
  end
  
  describe 'upload_trinity_with_edger' do
    before (:each) do
      @action = 'upload_trinity_with_edger'
      @template = :upload_trinity_with_edger
      @view_model = UploadTrinityWithEdgeR
      @process_data_method = :save
    end
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on POST'
    it_should_behave_like 'an action that processes data on POST'
  end
  
  describe 'add_sample_cmp_for_trinity_with_edger_transcripts' do
    before (:each) do
      @action = 'add_sample_cmp_for_trinity_with_edger_transcripts'
    end
    
    it_should_behave_like 'an action that requires authentication'
  end
  
  describe 'add_sample_cmp_for_trinity_with_edger_genes' do
    before (:each) do
      @action = 'add_sample_cmp_for_trinity_with_edger_genes'
    end
   
    it_should_behave_like 'an action that requires authentication'
  end
  
  describe 'query_diff_exp_transcripts' do
    before (:each) do
      @action = 'query_diff_exp_transcripts'
      @template = :query_diff_exp_transcripts
      @view_model = QueryDiffExpTranscripts
      @process_data_method = :query
    end
    
    it 'should render no transcript diff exp template when ' +
        'no transcript diff exp datasets' do
      @view_model.any_instance.stub(:set_attributes_and_defaults)
      @user = FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:dataset,
                          :user_id => @user.id,
                          :has_transcript_diff_exp => false)
      get @action
      response.should render_template :no_diff_exp_transcripts
    end    
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on POST'
    it_should_behave_like 'an action that processes data on POST'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'get_transcript_diff_exp_samples_for_dataset' do
    before (:each) do
      @action = 'get_transcript_diff_exp_samples_for_dataset'
      @template = :diff_exp_samples_for_dataset
      @view_model = QueryDiffExpTranscripts
    end
    
    it 'should render no transcript diff exp template when ' +
        'no transcript diff exp datasets' do
      @view_model.any_instance.stub(:set_attributes_and_defaults)
      @user = FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:dataset,
                          :user_id => @user.id,
                          :has_transcript_diff_exp => false)
      get @action
      response.should render_template :no_diff_exp_transcripts
    end    
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on get'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'get_transcript_fasta' do
    before (:each) do
      @action = 'get_transcript_fasta'
      @template = nil #Renders text instead of a template
      @view_model = GetTranscriptFasta
      @process_data_method = :query
    end    
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on get'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'get_gene_fastas' do
     before (:each) do
      @action = 'get_gene_fastas'
      @template = nil #Renders text instead of a template
      @view_model = GetGeneFastas
      @process_data_method = :query
    end    
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on get'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'query_diff_exp_genes' do
    before (:each) do
      @action = 'query_diff_exp_genes'
      @template = :query_diff_exp_genes
      @view_model = QueryDiffExpGenes
      @process_data_method = :query
    end
    
    it 'should render no gene diff exp template when ' +
        'no gene diff exp datasets' do
      @user = FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:dataset,
                          :user_id => @user.id,
                          :has_gene_diff_exp => false)
      get @action
      response.should render_template :no_diff_exp_gene
    end    
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on POST'
    it_should_behave_like 'an action that processes data on POST'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'get_gene_diff_exp_samples_for_dataset' do
    before (:each) do
      @action = 'get_gene_diff_exp_samples_for_dataset'
      @template = :diff_exp_samples_for_dataset
      @view_model = QueryDiffExpGenes
    end
    
    it 'should render no gene diff exp template when ' +
        'no gene diff exp datasets' do
      @view_model.any_instance.stub(:set_attributes_and_defaults)
      @user = FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:dataset,
                          :user_id => @user.id,
                          :has_gene_diff_exp => false)
      get @action
      response.should render_template :no_diff_exp_gene
    end      
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on get'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'query_transcript_isoforms' do
    before (:each) do
      @action = 'query_transcript_isoforms'
      @template = :query_transcript_isoforms
      @view_model = QueryTranscriptIsoforms
      @process_data_method = :query
    end
    
    it 'should render no transcript isoforms template when ' +
        'no transcript isoforms datasets exist' do
      @view_model.any_instance.stub(:set_attributes_and_defaults)
      @user = FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:dataset,
                          :user_id => @user.id,
                          :has_transcript_isoforms => false)
      get @action
      response.should render_template :no_transcript_isoforms
    end    
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on POST'
    it_should_behave_like 'an action that processes data on POST'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'get_transcript_isoforms_samples_for_dataset' do
     before (:each) do
      @action = 'get_transcript_isoforms_samples_for_dataset'
      @template = :transcript_isoforms_samples_for_dataset
      @view_model = QueryTranscriptIsoforms
      @process_data_method = :query
    end
    
    it 'should render no gene diff exp template when ' +
        'no transcript isoforms datasets exist' do
      @view_model.any_instance.stub(:set_attributes_and_defaults)
      @user = FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:dataset,
                          :user_id => @user.id,
                          :has_transcript_isoforms => false)
      get @action
      response.should render_template :no_transcript_isoforms
    end    
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on get'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'query_using_blastn' do
    before (:each) do
      @action = 'query_using_blastn'
      @get_template = :query_using_blastn
      @post_template = :blast_results
      @view_model = QueryUsingBlastn
      @process_data_method = :blast
    end
     
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on POST'
    it_should_behave_like 'an action that processes data on POST'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'get_blastn_gap_costs_for_match_and_mismatch_scores' do
    before (:each) do
      @action = 'get_blastn_gap_costs_for_match_and_mismatch_scores'
      @view_model = QueryUsingBlastn
    end
    
    it_should_behave_like 'an action that requires authentication'
  end
  
  describe 'query_using_tblastn' do
    before (:each) do
      @action = 'query_using_tblastn'
      @get_template = :query_using_tblastn
      @post_template = :blast_results
      @view_model = QueryUsingTblastn
      @process_data_method = :blast
    end
     
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on POST'
    it_should_behave_like 'an action that processes data on POST'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'get_tblastn_gap_costs_for_matrix' do
    before (:each) do
      @action = 'get_tblastn_gap_costs_for_matrix'
      @view_model = QueryUsingTblastn
    end
    
    it_should_behave_like 'an action that requires authentication'
  end
  
  describe 'query_using_tblastx' do
    before (:each) do
      @action = 'query_using_tblastx'
      @get_template = :query_using_tblastx
      @post_template = :blast_results
      @view_model = QueryUsingTblastx
      @process_data_method = :blast
    end
     
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that validates on POST'
    it_should_behave_like 'an action that processes data on POST'
    it_should_behave_like 'an action that requires a dataset'
  end
end
