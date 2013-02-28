# == Schema Information
#
# Table name: genes
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  name_from_program :string(255)      not null
#

require 'spec_helper'

describe Gene do
  
  before(:each) do
    @gene = FactoryGirl.build(:gene)
  end
  
  describe 'associations' do
#     belongs_to :dataset
#   has_many :transcripts#, :dependent => :destroy
#   has_many :differential_expression_tests
    it 'should have a dataset attribute' do
      @it.should respond_to(:dataset)
    end
    
    it 'should have a transcripts attribute' do
      @it.should respond_to(:transcripts)
    end
    
    it 'should have a differential expression tests attribute' do
      @it.should respond_to(:differential_expression_tests)
    end
    
    it 'should not have an fpkm_samples attribute'
  end
  
  describe 'validations' do
  end
end
