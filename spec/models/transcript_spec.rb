# == Schema Information
#
# Table name: transcripts
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  gene_id           :integer
#  name_from_program :string(255)      not null
#


require 'spec_helper'
require 'models/shared_examples.rb'

describe Transcript do
  before(:each) do
    @it = FactoryGirl.build(:transcript)
  end
  
  describe 'assocations', :type => :assocations do
    it 'should have a dataset attribute' do
      @it.should respond_to(:dataset)
    end
    it 'should have a gene attribute' do
      @it.should respond_to(:gene)
    end
    it 'should have a transcript_fpkm_tracking_information attribute' do
      @it.should respond_to(:transcript_fpkm_tracking_information)
    end
    it 'should have a differential_expression_tests attribute' do
      @it.should respond_to(:differential_expression_tests)
    end
    it 'should have an fpkm_samples attribute' do
      @it.should respond_to(:fpkm_samples)
    end
    it 'should have a transcript_has_go_terms attribute' do
      @it.should respond_to(:transcript_has_go_terms)
    end
    it 'should have a go_terms attribute' do
      @it.should respond_to(:go_terms)
    end
  end
  
  describe 'when destroyed', :type => :when_destroyed do
    before (:each) do @it.save! end
    
    it 'should not destroy the associated dataset' do
      @it.destroy
      Dataset.find(@it.dataset.id).should_not be_nil
    end
    
    it 'should not destroy the associated gene' do
      @it.gene.should_not be_nil
      @it.destroy
      Gene.find(@it.gene.id).should_not be_nil
    end
    
    it 'should destroy the associated transcript_fpkm_tracking_information' do
      FactoryGirl.create(:transcript_fpkm_tracking_information, :transcript => @it)
      TranscriptFpkmTrackingInformation.find_by_transcript_id(@it.id).should_not be_nil
      @it.destroy
      TranscriptFpkmTrackingInformation.find_by_transcript_id(@it.id).should be_nil
    end
    
    it 'should destroy the associated differential_expression_tests' do
      FactoryGirl.create(:differential_expression_test, 
                          :transcript => @it,
                          :gene => nil)
      FactoryGirl.create(:differential_expression_test, 
                          :transcript => @it,
                          :gene => nil)
      DifferentialExpressionTest.find_all_by_transcript_id(@it.id).count.should eq(2)
      @it.destroy
      DifferentialExpressionTest.find_all_by_transcript_id(@it.id).should be_empty
    end
    
    it 'should destroy the associated fpkm_samples' do
      FactoryGirl.create(:fpkm_sample, :transcript => @it)
      FactoryGirl.create(:fpkm_sample, :transcript => @it)
      FpkmSample.find_all_by_transcript_id(@it.id).count.should eq(2)
      @it.destroy
      FpkmSample.find_all_by_transcript_id(@it.id).should be_empty
    end
    
    it 'should destroy the associated transcript_has_go_terms' do
      FactoryGirl.create(:transcript_has_go_term, :transcript => @it)
      FactoryGirl.create(:transcript_has_go_term, :transcript => @it)
      TranscriptHasGoTerm.find_all_by_transcript_id(@it.id).count.should eq(2)
      @it.destroy
      TranscriptHasGoTerm.find_all_by_transcript_id(@it.id).should be_empty
    end
    
    it 'should not destroy the associated go_terms' do
      Transcript.find(@it.id).go_terms.count.should eq(0)
      @it.go_terms << FactoryGirl.create(:go_term)
      @it.go_terms << FactoryGirl.create(:go_term)
      @it.save!
      associated_go_terms = Transcript.find(@it.id).go_terms
      associated_go_terms.count.should eq(2)
      @it.destroy
      associated_go_terms.each do |associated_go_term|
        GoTerm.find(associated_go_term.id).should_not be_nil
      end
    end
  end
  
  describe 'validations', :type => :validations do
    describe 'dataset' do
      before(:each) do @attribute = 'dataset' end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'gene' do
      before(:each) do @attribute = 'gene' end
      
      it_should_behave_like 'an optional attribute'
    end
    
    describe 'transcript_fpkm_tracking_information' do
      before(:each) do @attribute = 'transcript_fpkm_tracking_information' end
      
      it_should_behave_like 'an optional attribute'
    end
    
    describe 'name_from_program' do
      before (:each) do @attribute = 'name_from_program' end
    
      it_should_behave_like 'a required attribute'
    end
  end 

end
