# == Schema Information
#
# Table name: genes
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  name_from_program :string(255)      not null
#

require 'spec_helper'
require 'models/shared_examples.rb'

describe Gene do
  
  before(:each) do
    @it = FactoryGirl.build(:gene)
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
    before (:each) do @it.save! end
  
    it 'should not destroy the associated dataset' do
      @it.destroy
      Dataset.find(@it.dataset.id).should_not be_nil
    end
    it 'should not destroy any associated transcripts' do
      t1 = FactoryGirl.create(:transcript, :gene_id => @it.id)
      t2 = FactoryGirl.create(:transcript, :gene_id => @it.id)
      Transcript.find_all_by_gene_id(@it.id).count.should eq(2)
      @it.destroy
      Transcript.find(t1.id).should_not be_nil
      Transcript.find(t2.id).should_not be_nil
    end
    it 'should destroy any associated differential expression tests' do
      FactoryGirl.create(:differential_expression_test, :gene_id => @it.id)
      FactoryGirl.create(:differential_expression_test, :gene_id => @it.id)
      DifferentialExpressionTest.find_all_by_gene_id(@it.id).count.should eq(2)
      @it.destroy
      DifferentialExpressionTest.find_all_by_gene_id(@it.id).should be_empty
    end
  end
  
  describe 'validations' do
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
    
    describe 'dataset' do
      before (:each) do @attribute = 'dataset' end
    
      it_should_behave_like 'a required attribute'
    end
    
    describe 'name_from_program' do
      before (:each) do @attribute = 'name_from_program' end
    
      it_should_behave_like 'a required attribute'
    end
  end
end
