# == Schema Information
#
# Table name: differential_expression_tests
#
#  id                   :integer          not null, primary key
#  gene_id              :integer
#  transcript_id        :integer
#  sample_comparison_id :integer          not null
#  test_status          :string(255)
#  sample_1_fpkm        :float
#  sample_2_fpkm        :float
#  log_fold_change      :float            not null
#  test_statistic       :float
#  p_value              :float            not null
#  fdr                  :float            not null
#

require 'spec_helper'
require 'models/shared_examples.rb'

describe DifferentialExpressionTest do
  before(:each) do
    @it = FactoryGirl.build(:differential_expression_test)
  end

  describe 'associations', :type => :associations do
    it 'should have a gene attribute' do
      @it.should respond_to(:gene)
    end
    it 'should have a transcript attribute' do
      @it.should respond_to(:transcript)
    end
    it 'should have a sample_comparison attribute' do
      @it.should respond_to(:sample_comparison)
    end
  end
  
  describe 'when deleted', :type => :when_deleted do
    before (:each) do @it.save! end
  
    it 'should not delete the associated gene' do
      @it.delete()
      Gene.find(@it.gene.id).should_not be_nil
    end
    it 'should not delete the associated transcript' do
      @it.gene = nil
      @it.transcript = FactoryGirl.create(:transcript)
      @it.delete()
      Transcript.find(@it.transcript.id).should_not be_nil
    end
    it 'should not delete the associated sample comparison' do
      @it.delete()
      SampleComparison.find(@it.sample_comparison.id).should_not be_nil
    end
  end
  
  describe 'validations', :type => :validations do
    it 'should save when all fields are valid' do
      @it.save!
    end
  
    describe 'gene' do
      before(:each) do @attribute = 'gene' end
      
      it_should_behave_like 'an optional attribute'
    end
    
    describe 'transcript' do
      before(:each) do @attribute = 'transcript' end
      
      it_should_behave_like 'an optional attribute'
    end
    
    describe 'sample_comparison' do
      before(:each) do @attribute = 'sample_comparison' end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'test_status' do
      before(:each) do @attribute = 'test_status' end
    
      it 'should be valid if one of the possible test statuses' do
        @it.instance_eval('POSSIBLE_TEST_STATUSES').each do |test_status|
          @it.test_status = test_status
          @it.should be_valid
        end
      end
      
      it 'should not be valid if not one of the possible test statuses' do
        ['', 'goats', 'Success'].each do |invalid_test_status|
          @it.test_status = invalid_test_status
          @it.should_not be_valid
        end
      end
    
      it_should_behave_like 'an optional attribute'
    end
    
    describe 'sample_1_fpkm' do
      before(:each) do @attribute = 'sample_1_fpkm' end
      
      it_should_behave_like 'an optional attribute'
      it_should_behave_like 'a number'
    end
    
    describe 'sample_2_fpkm' do
      before(:each) do @attribute = 'sample_2_fpkm' end
      
      it_should_behave_like 'an optional attribute'
      it_should_behave_like 'a number'
    end
    
    describe 'log_fold_change' do
      before(:each) do @attribute = 'log_fold_change' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'a number'
    end
    
    describe 'test_statistic' do
      before(:each) do @attribute = 'test_statistic' end
      
      it_should_behave_like 'an optional attribute'
      it_should_behave_like 'a number'
    end
    
    describe 'fdr' do
      before(:each) do @attribute = 'fdr' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'a number'
    end
    
    describe 'p_value' do
      before(:each) do @attribute = 'p_value' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'a number'
    end
  end
end
