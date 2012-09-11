require 'spec_helper'

describe QueryAnalysisController do

  describe "GET 'upload_main_menu'" do
    it "returns http success" do
      get 'upload_main_menu'
      response.should be_success
    end
  end

  describe "GET 'upload_reference_cuffdiff'" do
    it "returns http success" do
      get 'upload_reference_cuffdiff'
      response.should be_success
    end
  end

  describe "GET 'upload_de-novo_cuffdiff'" do
    it "returns http success" do
      get 'upload_de-novo_cuffdiff'
      response.should be_success
    end
  end

  describe "GET 'upload_de-novo_edgeR'" do
    it "returns http success" do
      get 'upload_de-novo_edgeR'
      response.should be_success
    end
  end

  describe "GET 'query_diff_exp_transcripts'" do
    it "returns http success" do
      get 'query_diff_exp_transcripts'
      response.should be_success
    end
  end

  describe "GET 'query_diff_exp_genes'" do
    it "returns http success" do
      get 'query_diff_exp_genes'
      response.should be_success
    end
  end

  describe "GET 'query_transcript_isoforms'" do
    it "returns http success" do
      get 'query_transcript_isoforms'
      response.should be_success
    end
  end

  describe "GET 'query_gene_isoforms'" do
    it "returns http success" do
      get 'query_gene_isoforms'
      response.should be_success
    end
  end

  describe "GET 'query_blast_db'" do
    it "returns http success" do
      get 'query_blast_db'
      response.should be_success
    end
  end

end
