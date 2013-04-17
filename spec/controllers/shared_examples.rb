shared_examples_for 'an action that requires authentication' do
  before(:each) do
    @view_model.any_instance.stub(:set_attributes_and_defaults)
    @view_model.any_instance.stub(:valid?).and_return(true)
  end
  
  describe 'when not signed in' do
    it "should redirect from 'query_diff_exp_transcripts'" do
      get @action
      response.should redirect_to(new_user_session_path)
    end 
  end
  
  describe 'when signed in' do
    before (:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    
    it 'should succeed for GET' do
      get @action
      response.should be_success
    end
  end
end

shared_examples_for 'an action that has form data' do
  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    FactoryGirl.create(:dataset, :user_id => @user.id)
    @view_model.any_instance.stub(:set_attributes_and_defaults)
    @view_model.any_instance.stub(:valid?).and_return(true)
    @view_model.any_instance.stub(@query_or_upload_method)
  end
  
  it 'should succeed for POST' do
    get @action
    response.should be_success
  end
  
  it 'should render normal page for POST' do
    post @action
    response.should render_template @template
  end
  
  it 'should validate the form intput' do
    @view_model.any_instance.should_receive(:valid?)
    post @action
  end
  
  it 'should query or upload when given valid form data' do
    @view_model.any_instance.stub(:valid?).and_return(true)
    @view_model.any_instance.should_receive(@query_or_upload_method)
    post @action
  end
  
  it 'should not query or upload when given invalid form data' do
    @view_model.any_instance.stub(:valid?).and_return(false)
    @view_model.any_instance.should_not_receive(@query_or_upload_method)
    post @action
  end
end

shared_examples_for 'an action that requires a dataset' do
  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @view_model.any_instance.stub(:set_attributes_and_defaults)
    @view_model.any_instance.stub(:valid?).and_return(true)
  end
  
  it 'should render the no datasets template when no datasets available' do
    get @action
    response.should render_template :no_datasets  
  end
  
  it 'should render normal page' do
    FactoryGirl.create(:dataset, :user_id => @user.id)
    get @action
    response.should render_template @template
  end
end


