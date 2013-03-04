# == Schema Information
#
# Table name: samples
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  dataset_id :integer          not null
#

require 'spec_helper'

describe Sample do
  before(:each) do
    @it = FactoryGirl.build(:sample)
  end
  
  describe 'assocations' do
    it 'should have a dataset attribute' do
      @it.should respond_to(:dataset)
    end
    it 'should have an fpkm_samples attribute' do
      @it.should respond_to(:fpkm_samples)
    end
    it 'should have a sample_comparisons attribute' do
      @it.should respond_to(:sample_comparisons)
    end
    it 'should have a samples attribute' do
      @it.should respond_to(:samples)
    end
  end
  
  describe 'when destroyed' do
    before(:each) do 
      @it.save!
    end
    
    it 'should destroy all associated sample comparisons' do
      FactoryGirl.create(:sample_comparison, :sample_1_id => @it.id)
      FactoryGirl.create(:sample_comparison, :sample_1_id => @it.id)
      SampleComparison.find_all_by_sample_1_id(@it.id).count.should eq(2)
      @it.destroy
      SampleComparison.find_all_by_sample_1_id(@it.id).should be_empty
    end
    
    it 'should destroy all associated fpkm samples'
    it 'should not destroy the associated dataset'
    it 'should not destroy the associated samples'
  end
  
  describe 'validations' do
    it 'should be valid when all fields are valid' do
      @it.should be_valid
    end
    
    it 'should require a name' do
      [nil, ""].each do |invalid_value|
        @it.name = invalid_value
        @it.should_not be_valid
      end
    end
  end
end
