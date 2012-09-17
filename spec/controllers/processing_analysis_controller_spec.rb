require 'spec_helper'

describe ProcessingAnalysisController do

  describe "GET 'main_menu'" do
    it "returns http success" do
      get 'main_menu'
      response.should be_success
    end
  end

  describe "GET 'quality_filtering'" do
    it "returns http success" do
      get 'quality_filtering'
      response.should be_success
    end
  end

  describe "GET 'reference_analysis'" do
    it "returns http success" do
      get 'reference_analysis'
      response.should be_success
    end
  end

  describe "GET 'reference_analysis_isoforms_only'" do
    it "returns http success" do
      get 'reference_analysis_isoforms_only'
      response.should be_success
    end
  end

  describe "GET 'de_novo_analysis_edgeR'" do
    it "returns http success" do
      get 'de_novo_analysis_edgeR'
      response.should be_success
    end
  end

  describe "GET 'de_novo_analysis_cuffdiff'" do
    it "returns http success" do
      get 'de_novo_analysis_cuffdiff'
      response.should be_success
    end
  end

end
