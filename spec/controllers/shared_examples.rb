shared_examples_for 'an action that requires authentication' do
  before(:each) do
    if @view_model
      @view_model.any_instance.stub(:set_attributes_and_defaults)
      @view_model.any_instance.stub(:valid?).and_return(true)
      if @process_data_method
        @view_model.any_instance.stub(@process_data_method)
      end
    end
  end
  
  describe 'when not signed in' do
    it "should redirect to the sign in '" do
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

shared_examples_for 'an action that validates on POST' do
  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    FactoryGirl.create(:dataset, :user_id => @user.id)
    @view_model.any_instance.stub(:set_attributes_and_defaults)
    @view_model.any_instance.stub(:valid?).and_return(true)
    if @process_data_method
      @view_model.any_instance.stub(@process_data_method)
    end
  end

  it 'should validate the form intput' do
    @view_model.any_instance.should_receive(:valid?)
    post @action
  end
end

shared_examples_for 'an action that processes data on POST' do
  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    FactoryGirl.create(:dataset, :user_id => @user.id)
    @view_model.any_instance.stub(:set_attributes_and_defaults)
    @view_model.any_instance.stub(:valid?).and_return(true)
    @view_model.any_instance.stub(@process_data_method)
  end
  
  it 'should succeed for POST' do
    get @action
    response.should be_success
  end
  
  it 'should render normal page for POST' do
    post @action
    if @template
      response.should render_template @template
    else
      response.should render_template @post_template
    end
  end
  
  it 'should query or upload when given valid form data' do
    @view_model.any_instance.stub(:valid?).and_return(true)
    @view_model.any_instance.should_receive(@process_data_method)
    post @action
  end
  
  it 'should not query or upload when given invalid form data' do
    @view_model.any_instance.stub(:valid?).and_return(false)
    @view_model.any_instance.should_not_receive(@process_data_method)
    post @action
  end
end

shared_examples_for 'an action that validates on get' do
  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    FactoryGirl.create(:dataset, :user_id => @user.id)
    @view_model.any_instance.stub(:set_attributes_and_defaults)
    @view_model.any_instance.stub(:valid?).and_return(true)
    if @process_data_method
      @view_model.any_instance.stub(@process_data_method)
    end
  end
  
  it 'should validate the form intput' do
    @view_model.any_instance.should_receive(:valid?)
    get @action
  end
end

shared_examples_for 'an action that processes data on GET' do
   before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    FactoryGirl.create(:dataset, :user_id => @user.id)
    @view_model.any_instance.stub(:set_attributes_and_defaults)
    @view_model.any_instance.stub(:valid?).and_return(true)
    if @process_data_method
      @view_model.any_instance.stub(@process_data_method)
    end
  end  
  
  it 'should query or upload when given valid form data' do
    @view_model.any_instance.stub(:valid?).and_return(true)
    @view_model.any_instance.should_receive(@process_data_method)
    get @action
  end
  
  it 'should not query or upload when given invalid form data' do
    @view_model.any_instance.stub(:valid?).and_return(false)
    @view_model.any_instance.should_not_receive(@process_data_method)
    get @action
  end
end

shared_examples_for 'an action that requires a dataset' do
  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @view_model.any_instance.stub(:set_attributes_and_defaults)
    @view_model.any_instance.stub(:valid?).and_return(true)
    if @process_data_method
      @view_model.any_instance.stub(@process_data_method)
    end
  end
  
  it 'should render the no datasets template when no datasets available' do
    get @action
    response.should render_template :no_datasets  
  end
  
  it 'should render normal page' do
    FactoryGirl.create(:dataset, :user_id => @user.id)
    get @action
    if @template
      response.should render_template @template
    else
      response.should render_template @get_template
    end
  end
end


