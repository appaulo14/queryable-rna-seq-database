require 'spec_helper'

describe QueryAnalysisController do
  
  it 'should have the same routes as the ones in routes.rb' do
    Rails.application.routes.routes.map do |route|
      if route.defaults[:controller] == 'query_analysis'
        get route.defaults[:action]
      end
    end
  end
  
  describe 'GET requests for user not signed in' do  
    it "should redirect from 'upload_cuffdiff'" do
      get 'upload_cuffdiff'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'upload_trinity_with_edger'" do
      get 'upload_trinity_with_edger'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'query_diff_exp_transcripts'" do
      get 'query_diff_exp_transcripts'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'get_transcript_fasta'" do
      get 'get_transcript_fasta'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'get_gene_fastas'" do
      get 'get_gene_fastas'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'query_diff_exp_genes'" do
      get 'query_diff_exp_genes'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'query_transcript_isoforms'" do
      get 'query_transcript_isoforms'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'query_using_blastn'" do
      get 'query_using_blastn'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'get_blastn_gap_costs_for_match_and_mismatch_scores'" do
      get 'get_blastn_gap_costs_for_match_and_mismatch_scores'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'query_using_tblastn'" do
      get 'query_using_tblastn'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'get_tblastn_gap_costs_for_matrix'" do
      get 'get_tblastn_gap_costs_for_matrix'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'query_using_tblastx'" do
      get 'query_using_tblastx'
      response.should redirect_to(new_user_session_path)
    end
  end
  
  #### When Signed In ####
  describe 'when user signed in', :type => :when_signed_in do 
    before (:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
      
    describe 'GET request' do  
      it "should succeed for 'upload_cuffdiff'" do
        get 'upload_cuffdiff'
        response.should be_success
      end
      
      it "should succeed for 'upload_trinity_with_edger'" do
        get 'upload_trinity_with_edger'
        response.should be_success
      end
      
      it "should succeed for 'query_diff_exp_transcripts'" do
        get 'query_diff_exp_transcripts'
        response.should be_success
        response.should render_template :no_datasets
      end
      
      it "should succeed for 'get_transcript_fasta'" do
        get 'get_transcript_fasta'
        response.should be_success
      end
      
      it "should succeed for 'get_gene_fastas'" do
        get 'get_gene_fastas'
        response.should be_success
      end
      
      it "should succeed for 'query_diff_exp_genes'" do
        get 'query_diff_exp_genes'
        response.should be_success
      end
      
      it "should succeed for 'query_transcript_isoforms'" do
        get 'query_transcript_isoforms'
        response.should be_success
      end
      
      it "should succeed for 'query_using_blastn'" do
        get 'query_using_blastn'
        response.should be_success
      end
      
      it "should succeed for 'get_blastn_gap_costs_for_match_and_mismatch_scores'" do
        get 'get_blastn_gap_costs_for_match_and_mismatch_scores'
        response.should be_success
      end
      
      it "should succeed for 'query_using_tblastn'" do
        get 'query_using_tblastn'
        response.should be_success
      end
      
      it "should succeed for 'get_tblastn_gap_costs_for_matrix'" do
        get 'get_tblastn_gap_costs_for_matrix'
        response.should be_success
      end
      
      it "should succeed for 'query_using_tblastx'" do
        get 'query_using_tblastx'
        response.should be_success
      end
    end
    
    describe 'POST request', :type => :post_request do
      it "should succeed for 'upload_cuffdiff'" do
        UploadCuffdiff.any_instance.stub(:save)
        post 'upload_cuffdiff', :upload_cuffdiff => {} 
        response.should be_success
      end
      
      it "should succeed for 'upload_trinity_with_edger'" do
        UploadTrinityWithEdgeR.any_instance.stub(:set_attributes_and_defaults)
#        UploadTrinityWithEdgeR.any_instance.stub(:valid?).with(true)
#        UploadTrinityWithEdgeR.any_instance.stub(:save)
        post 'upload_trinity_with_edger', :upload_trinity_with_edger => {}
        response.should be_success
      end
      
      it "should succeed for 'query_diff_exp_transcripts'" do
        QueryDiffExpTranscripts.any_instance.stub(:save)
        QueryDiffExpTranscripts.any_instance.should_receive(:goat)
        post 'query_diff_exp_transcripts', :query_diff_exp_transcripts => {}
        response.should be_success
      end
      
      it "should succeed for 'query_diff_exp_genes'" do
        QueryDiffExpTranscripts.any_instance.stub(:save)
        post 'query_diff_exp_genes', :query_diff_exp_genes => {}
        response.should be_success
      end
      
      it 'should redirect if user has not datasets for gene diff exp??'
      
      it "should succeed for 'query_transcript_isoforms'" do
        post 'query_transcript_isoforms', :query_transcript_isoforms => {}
        response.should be_success
      end
      
      it "should succeed for 'query_using_blastn'" do
        post 'query_using_blastn', :query_using_blastn => {}
        response.should be_success
      end
      
      it "should succeed for 'query_using_tblastn'" do
        post 'query_using_blastn', :query_using_blastn => {}
        response.should be_success
      end
      
      it "should succeed for 'query_using_tblastx'" do
        post 'query_using_tblastx', :query_using_tblastx => {}
        response.should be_success
      end
    end
 end
end
