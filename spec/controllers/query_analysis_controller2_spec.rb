require 'spec_helper'

describe QueryAnalysisController do
  describe 'query_diff_exp_transcripts' do
    describe 'when not signed in' do
      it "should redirect from 'query_diff_exp_transcripts'" do
        get 'query_diff_exp_transcripts'
        response.should redirect_to(new_user_session_path)
      end 
    end
    
    describe 'when signed in' do
      before (:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end
  
      it 'should render the no datasets template when no datasets available' do
        get 'query_diff_exp_transcripts'
        response.should render_template :no_datasets  
      end
      it 'should render no transcript diff exp template when ' +
         'no transcript diff exp datasets' do
        FactoryGirl.create(:dataset,
                            :user_id => @user.id,
                            :has_transcript_diff_exp => false)
        get 'query_diff_exp_transcripts'
        response.should render_template :no_diff_exp_transcripts
      end
      
      describe 'when transcript diff exp datasets are available' do
        before (:each) do 
          FactoryGirl.create(:dataset, :user_id => @user.id)
        end
        
        describe 'GET' do
          before (:each) do
            QueryDiffExpTranscripts.any_instance.stub(:set_attributes_and_defaults)
          end
          
          it 'should render normal page' do
            get 'query_diff_exp_transcripts'
            response.should render_template :query_diff_exp_transcripts
          end
        end
        
        describe 'POST', :type => :post do
          before (:each) do
            QueryDiffExpTranscripts.any_instance.stub(:set_attributes_and_defaults)
            QueryDiffExpTranscripts.any_instance.stub(:query)
          end
        
          it 'should render normal page' do
            post 'query_diff_exp_transcripts'
            response.should render_template :query_diff_exp_transcripts
          end
          
          it 'should validate the format intput' do
            QueryDiffExpTranscripts.any_instance.should_receive(:valid?)
            post 'query_diff_exp_transcripts'
          end
          
          it 'should call qdet.save when given valid object' do
            QueryDiffExpTranscripts.any_instance.stub(:valid?).and_return(true)
            QueryDiffExpTranscripts.any_instance.should_receive(:query)
            post 'query_diff_exp_transcripts'
          end
          
          it 'should not call qdet.save when not given valid form data' do
            QueryDiffExpTranscripts.any_instance.stub(:valid?).and_return(false)
            QueryDiffExpTranscripts.any_instance.should_not_receive(:query)
            post 'query_diff_exp_transcripts'
          end
        end
      end
    end
  end
end
