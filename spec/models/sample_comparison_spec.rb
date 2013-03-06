# == Schema Information
#
# Table name: sample_comparisons
#
#  id          :integer          not null, primary key
#  sample_1_id :integer          not null
#  sample_2_id :integer          not null
#

require 'spec_helper'

describe SampleComparison do
  before (:each) do
    @it = FactoryGirl.build(:sample_comparison)
  end
  
  describe 'assocations' do
    it 'should have a sample_1 attribute' do
      @it.should respond_to(:sample_1)
    end
    it 'should have a sample_2 attribute' do
      @it.should respond_to(:sample_2)
    end
    it 'should have a differential_expression_tests attribute' do
      @it.should respond_to(:differential_expression_tests)
    end
  end
  
  describe 'when destroyed' do
    before (:each) do
      @it.save!
    end
    
    it 'should destroy all associated differential expression tests' do
      FactoryGirl.create(:differential_expression_test, 
                         :sample_comparison_id => @it.id)
      FactoryGirl.create(:differential_expression_test, 
                         :sample_comparison_id => @it.id)
      DifferentialExpressionTest.find_all_by_sample_comparison_id(@it.id).count.should eq(2)
      @it.destroy
      DifferentialExpressionTest.find_all_by_sample_comparison_id(@it.id).should be_empty
    end
    
    it 'should not destroy the associated sample 1' do
      @it.destroy
      Sample.find_by_id(@it.sample_1.id).should_not be_nil
    end
    
    it 'should not destroy the associated sample 2' do
      @it.destroy
      Sample.find_by_id(@it.sample_2.id).should_not be_nil
    end
  end
  
  describe 'validations' do
    it 'should be valid when all fields are valid' do
      @it.should be_valid
    end
    
    it 'should require a sample 1' do
      @it.sample_1 = nil
      @it.should_not be_valid
    end
    
    it 'should require a sample 2' do
      @it.sample_2 = nil
      @it.should_not be_valid
    end
  end
end
