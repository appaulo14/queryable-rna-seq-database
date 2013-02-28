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
    it "should redirect from 'upload_main_menu'" do
      get 'upload_main_menu'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'welcome'" do
      get 'welcome'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'upload_cuffdiff'" do
      get 'upload_cuffdiff'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'upload_trinity_with_edger_transcripts'" do
      get 'upload_trinity_with_edger_transcripts'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'upload_trinity_with_edger_transcripts_and_genes'" do
      get 'upload_trinity_with_edger_transcripts_and_genes'
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
    
    it "should redirect from 'blastn'" do
      get 'blastn'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'get_blastn_gap_costs_for_match_and_mismatch_scores'" do
      get 'get_blastn_gap_costs_for_match_and_mismatch_scores'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'tblastn'" do
      get 'tblastn'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'get_tblastn_gap_costs_for_matrix'" do
      get 'get_tblastn_gap_costs_for_matrix'
      response.should redirect_to(new_user_session_path)
    end
    
    it "should redirect from 'tblastx'" do
      get 'tblastx'
      response.should redirect_to(new_user_session_path)
    end
  end
  
  describe 'when user signed in' do 
    before (:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
      
    describe 'GET request' do
      it "should succeed for '/'" do
        get '/'
        response.status.should be_success
      end
      
      it "should succeed for 'upload_main_menu'" do
        get 'upload_main_menu'
        response.should be_success
      end
      
      it "should succeed for 'welcome'" do
        get 'welcome'
        response.should be_success
      end
      
      it "should succeed for 'upload_cuffdiff'" do
        get 'upload_cuffdiff'
        response.should be_success
      end
      
      it "should succeed for 'upload_trinity_with_edger_transcripts'" do
        get 'upload_trinity_with_edger_transcripts'
        response.should be_success
      end
      
      it "should succeed for 'upload_trinity_with_edger_transcripts_and_genes'" do
        get 'upload_trinity_with_edger_transcripts_and_genes'
        response.should be_success
      end
      
      it "should succeed for 'query_diff_exp_transcripts'" do
        get 'query_diff_exp_transcripts'
        response.should be_success
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
      
      it "should succeed for 'blastn'" do
        get 'blastn'
        response.should be_success
      end
      
      it "should succeed for 'get_blastn_gap_costs_for_match_and_mismatch_scores'" do
        get 'get_blastn_gap_costs_for_match_and_mismatch_scores'
        response.should be_success
      end
      
      it "should succeed for 'tblastn'" do
        get 'tblastn'
        response.should be_success
      end
      
      it "should succeed for 'get_tblastn_gap_costs_for_matrix'" do
        get 'get_tblastn_gap_costs_for_matrix'
        response.should be_success
      end
      
      it "should succeed for 'tblastx'" do
        get 'tblastx'
        response.should be_success
      end
    end
    
    describe 'POST request' do
      it "should succeed for 'upload_cuffdiff'" do
        post 'upload_cuffdiff', 
           :upload_cuffdiff => {} 
        response.should be_success
      end
      
      it "should succeed for 'upload_trinity_with_edger_transcripts'" do
        post 'upload_trinity_with_edger_transcripts', 
            :upload_trinity_with_edger_transcripts => {}
        response.should be_success
      end
      
      it "should succeed for 'upload_trinity_with_edger_transcripts_and_genes'" do
        post 'upload_trinity_with_edger_transcripts_and_genes',
            :upload_trinity_with_edger_transcripts_and_genes => {}
        response.should be_success
      end
      
      it "should succeed for 'query_diff_exp_transcripts'" do
        post 'query_diff_exp_transcripts', :query_diff_exp_transcripts => {}
        response.should be_success
      end
      
      it "should succeed for 'query_diff_exp_genes'" do
        post 'query_diff_exp_genes', :query_diff_exp_genes => {}
        response.should be_success
      end
      
      it 'should redirect if user has not datasets for gene diff exp??'
      
      it "should succeed for 'query_transcript_isoforms'" do
        post 'query_transcript_isoforms', :query_transcript_isoforms => {}
        response.should be_success
      end
      
      it "should succeed for 'blastn'" do
        post 'blastn', :blastn_query => {}
        response.should be_success
      end
      
      it "should succeed for 'tblastn'" do
        post 'tblastn', :tblastn_query => {}
        response.should be_success
      end
      
      it "should succeed for 'tblastx'" do
        post 'tblastx', :tblastx_query => {}
        response.should be_success
      end
    end
 end
end
