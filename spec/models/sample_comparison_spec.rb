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
  
  describe 'assocations', :type => :associations do
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
  
  describe 'when deleted', :type => :when_deleted do
    before (:each) do
      @it.save!
    end
    
    it 'should delete all associated differential expression tests' do
      FactoryGirl.create(:differential_expression_test, 
                         :sample_comparison_id => @it.id)
      FactoryGirl.create(:differential_expression_test, 
                         :sample_comparison_id => @it.id)
      DifferentialExpressionTest.find_all_by_sample_comparison_id(@it.id).count.should eq(2)
      @it.delete()
      DifferentialExpressionTest.find_all_by_sample_comparison_id(@it.id).should be_empty
    end
    
    it 'should not delete the associated sample 1' do
      @it.delete()
      Sample.find_by_id(@it.sample_1.id).should_not be_nil
    end
    
    it 'should not delete the associated sample 2' do
      @it.delete()
      Sample.find_by_id(@it.sample_2.id).should_not be_nil
    end
  end
  
  describe 'validations' do
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
    
    describe 'sample_1' do
      before(:each) do @attribute = 'sample_1' end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'sample_2' do
      before(:each) do @attribute = 'sample_2' end
      
      it_should_behave_like 'a required attribute'
    end
  end
end
