# == Schema Information
#
# Table name: differential_expression_tests
#
#  id                   :integer          not null, primary key
#  gene_id              :integer
#  transcript_id        :integer
#  sample_comparison_id :integer          not null
#  test_status          :string(255)      not null
#  sample_1_fpkm        :float            not null
#  sample_2_fpkm        :float            not null
#  log_fold_change      :float            not null
#  test_statistic       :float            not null
#  p_value              :float            not null
#  fdr                  :float            not null
#

require 'spec_helper'
require 'models/shared_examples.rb'

describe DifferentialExpressionTest do
  before(:each) do
    @it = FactoryGirl.build(:differential_expression_test)
  end

  describe 'associations' do
    it 'should have a gene attribute'
    it 'should have a transcript attribute'
    it 'should have a sample_comparison attribute'
  end
  
  describe 'when destroyed' do
    it 'should not destroy the associated gene'
    it 'should not destroy the associated transcript'
    it 'should not destroy the associated sample comparison'
  end
  
  describe 'validations' do
    it 'should save when all fields are valid'
  
    describe 'gene' do
      before(:each) do @attribute = 'gene' end
      
      it_should_behave_like 'an optional attribute'
    end
    
    describe 'transcript' do
      before(:each) do @attribute = 'transcript' end
      
      it_should_behave_like 'an optional attribute'
    end
    
    describe 'sample_comparison' do
    end
    
    describe 'test_status' do
      before(:each) do @attribute = 'test_status' end
    
      it 'should be valid if one of the possible test statuses'
      
      it 'should not be valid if not one of the possible test statuses'
    
      it_should_behave_like 'a string'
    end
    
    describe 'sample_1_fpkm' do
      before(:each) do @attribute = 'sample_1_fpkm' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an ActiveRecord-customized float greater than 0'
    end
    
    describe 'sample_2_fpkm' do
      before(:each) do @attribute = 'sample_2_fpkm' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an ActiveRecord-customized float greater than 0'
    end
    
    describe 'log_fold_change' do
      before(:each) do @attribute = 'log_fold_change' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an ActiveRecord-customized float greater than 0'
    end
    
    describe 'test_statistic' do
      before(:each) do @attribute = 'test_statistic' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an ActiveRecord-customized float greater than 0'
    end
    
    describe 'fdr' do
      before(:each) do @attribute = 'fdr' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an ActiveRecord-customized float greater than 0'
    end
    
    describe 'p_value' do
      before(:each) do @attribute = 'p_value' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an ActiveRecord-customized float greater than 0'
    end
  end
end
