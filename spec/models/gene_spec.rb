# == Schema Information
#
# Table name: genes
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  name_from_program :string(255)      not null
#

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
    it 'should have a dataset attribute' do
      @it.should respond_to(:dataset)
    end
    
    it 'should have a transcripts attribute' do
      @it.should respond_to(:transcripts)
    end
    
    it 'should have a differential expression tests attribute' do
      @it.should respond_to(:differential_expression_tests)
    end
  end
  
  describe 'when destroyed' do
    it 'should destroy any associated differential expression tests'
    it 'should not destroy any associated transcripts'
    it 'should not destroy the associated dataset'
  end
  
  describe 'validations' do
    it 'should require a name_from_program'
    it 'should require a dataset'
  end
end
