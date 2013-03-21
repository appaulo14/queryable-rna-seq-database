# == Schema Information
#
# Table name: fpkm_samples
#
#  id            :integer          not null, primary key
#  transcript_id :integer          not null
#  sample_id     :integer
#  fpkm          :string(255)      not null
#  fpkm_hi       :string(255)
#  fpkm_lo       :string(255)
#  status        :string(255)
#

require 'spec_helper'
require 'models/shared_examples.rb'

describe FpkmSample do
  before(:each) do 
    @it = FactoryGirl.build(:fpkm_sample)
  end
  
  describe 'associations', :type => :assocations do
    it 'should have a transcript attribute' do
      @it.should respond_to(:transcript)
    end
    
    it 'should have a sample attribute' do
      @it.should respond_to(:sample)
    end
  end
  
  describe 'when destroyed', :type => :when_destroyed do
    before (:each) do @it.save! end
  
    it 'should not destroy the associated transcript' do
      @it.destroy
      Transcript.find(@it.transcript.id).should_not be_nil
    end
    
    it 'should not destroy the associated sample' do
      @it.destroy
      Sample.find(@it.sample.id).should_not be_nil
    end
  end
  
  describe 'validations', :type => :validations do
    describe 'fpkm' do
      before(:each) do @attribute = 'fpkm' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'a float >= 0 that is stored as a string'
    end
    
    describe 'fpkm_lo' do
      before(:each) do @attribute = 'fpkm_lo' end
      
      it_should_behave_like 'an optional attribute'
      it_should_behave_like 'a float >= 0 that is stored as a string'
    end
    
    describe 'fpkm_hi' do 
      before(:each) do @attribute = 'fpkm_hi' end
      
      it_should_behave_like 'an optional attribute'
      it_should_behave_like 'a float >= 0 that is stored as a string'
    end
   
    describe 'status' do
      before(:each) do @attribute = 'status' end
      
      it 'should be valid for the valid possible statuses' do
        @it.instance_eval('POSSIBLE_STATUSES').each do |status|
          @it.status = status
          @it.should be_valid
        end
      end
      
      it 'should not be valid for statuses other than the valid ones' do
        ['', 'goats', 'Success'].each do |invalid_status|
          @it.status = invalid_status
          @it.should_not be_valid
        end
      end
      
      it_should_behave_like 'a required attribute'
    end
  end
end
