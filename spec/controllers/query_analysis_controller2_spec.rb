require 'spec_helper'
require 'controllers/shared_examples.rb'

describe QueryAnalysisController do
  describe 'upload_cuffdiff' do
    before (:each) do
      @action = 'upload_cuffdiff'
      @template = :upload_cuffdiff
      @view_model = UploadCuffdiff
      @query_or_upload_method = :save
    end
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that has form data'
  end
  
  describe 'upload_fasta_sequences' do
    before (:each) do
      @action = 'upload_fasta_sequences'
      @template = :upload_fasta_sequences
      @view_model = UploadFastaSequences
      @query_or_upload_method = :save
    end
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that has form data'
  end
  
  describe 'upload_trinity_with_edger' do
    before (:each) do
      @action = 'upload_trinity_with_edger'
      @template = :upload_trinity_with_edger
      @view_model = UploadTrinityWithEdgeR
      @query_or_upload_method = :save
    end
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that has form data'
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
      @query_or_upload_method = :query
    end
    
    it 'should render no transcript diff exp template when ' +
        'no transcript diff exp datasets' do
      @user = FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:dataset,
                          :user_id => @user.id,
                          :has_transcript_diff_exp => false)
      get 'query_diff_exp_transcripts'
      response.should render_template :no_diff_exp_transcripts
    end    
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that has form data'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'get_transcript_diff_exp_samples_for_dataset' do
    before (:each) do
      @action = 'get_transcript_diff_exp_samples_for_dataset'
      @template = :diff_exp_samples_for_dataset
      @view_model = QueryDiffExpTranscripts
      @query_or_upload_method = :query
    end
    
    it 'should render no transcript diff exp template when ' +
        'no transcript diff exp datasets' do
      @user = FactoryGirl.create(:user)
      sign_in @user
      FactoryGirl.create(:dataset,
                          :user_id => @user.id,
                          :has_transcript_diff_exp => false)
      get 'query_diff_exp_transcripts'
      response.should render_template :no_diff_exp_transcripts
    end    
    
    it_should_behave_like 'an action that requires authentication'
    it_should_behave_like 'an action that has form data'
    it_should_behave_like 'an action that requires a dataset'
  end
  
  describe 'get_transcript_fasta' do
  end
  
  describe 'get_gene_fastas' do
  end
  
  describe 'query_diff_exp_genes' do
  end
  
#   describe 'query_using_blastn' do
#     before (:each) do
#       @action = 'query_using_blastn'
#       @template = :query_using_blastn
#       @view_model = QueryUsingBlastn
#       @query_or_upload_method = :blast
#     end
#     
#     it_should_behave_like 'an action that requires authentication'
#     it_should_behave_like 'an action that has form data'
#     it_should_behave_like 'an action that requires a dataset'
#   end
end
