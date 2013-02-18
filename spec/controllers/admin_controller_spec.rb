require 'spec_helper'

describe AdminController do

  describe "GET 'view_user_information'" do
    it "returns http success" do
      get 'view_user_information'
      response.should be_success
    end
  end

  describe "GET 'add_new_user_to_system'" do
    it "returns http success" do
      get 'add_new_user_to_system'
      response.should be_success
    end
  end

  describe "GET 'delete_datasets_from_database'" do
    it "returns http success" do
      get 'delete_datasets_from_database'
      response.should be_success
    end
  end

end
