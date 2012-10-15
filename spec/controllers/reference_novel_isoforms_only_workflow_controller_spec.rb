require 'spec_helper'

describe ReferenceNovelIsoformsOnlyWorkflowController do

  describe "GET 'tophat_configure'" do
    it "returns http success" do
      get 'tophat_configure'
      response.should be_success
    end
  end

  describe "GET 'tophat_complete'" do
    it "returns http success" do
      get 'tophat_complete'
      response.should be_success
    end
  end

  describe "GET 'cufflinks_configure'" do
    it "returns http success" do
      get 'cufflinks_configure'
      response.should be_success
    end
  end

  describe "GET 'cufflinks_complete'" do
    it "returns http success" do
      get 'cufflinks_complete'
      response.should be_success
    end
  end

  describe "GET 'cuffcompare_configure'" do
    it "returns http success" do
      get 'cuffcompare_configure'
      response.should be_success
    end
  end

  describe "GET 'cuffcompare_complete'" do
    it "returns http success" do
      get 'cuffcompare_complete'
      response.should be_success
    end
  end

  describe "GET 'in_progress'" do
    it "returns http success" do
      get 'in_progress'
      response.should be_success
    end
  end

end
