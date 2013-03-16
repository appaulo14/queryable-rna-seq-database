# == Schema Information
#
# Table name: transcript_fpkm_tracking_informations
#
#  transcript_id :integer          not null, primary key
#  class_code    :string(255)      not null
#  length        :integer          not null
#  coverage      :string(255)
#

require 'spec_helper'
require 'models/shared_examples.rb'

describe TranscriptFpkmTrackingInformation do
  before(:each) do
    @it = FactoryGirl.build(:transcript_fpkm_tracking_information)
  end
  
  describe 'assocations' do
    it 'should have a transcript attribute' do
      @it.should respond_to(:transcript)
    end
  end
  
  describe 'when destroyed' do
    it 'should not destroy the associated transcript' do
      associated_transcript = @it.transcript
      @it.destroy
      Transcript.find(associated_transcript.id).should_not be_nil
    end
  end
  
  describe 'validations' do
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
    
    it 'should be valid when all fields are valid' do
      @it.should be_valid
    end
    
    it 'should require a transcript' do
      @it.transcript = nil
      @it.should_not be_valid
    end
    
    describe 'class code' do
      before(:each) do
        @attribute = 'class_code'
      end
      
      it 'should requie a class code' do
        @it.class_code = nil
        @it.should_not be_valid
      end
      
      it 'should be valid if class code is one of the possible class codes' do
        @it.instance_eval('POSSIBLE_CLASS_CODES').each do |class_code|
          @it.class_code = class_code
          @it.should be_valid
        end
      end
      
      describe 'non-approved class codes' do
        it 'should not be valid for "a"' do
          @it.class_code = 'a'
          @it.should_not be_valid
        end
        it 'should not be valid for "z"' do
          @it.class_code = 'z'
          @it.should_not be_valid
        end
        it 'should not be valid for "q"' do
          @it.class_code = 'q'
          @it.should_not be_valid
        end

      end 
      
      it_should_behave_like 'a string'
    end
    
    describe 'length' do
      before(:each) do
        @attribute = 'length'
      end
    
      it 'should require a length' do
        @it.length = nil
        @it.should_not be_valid
      end
      
      it_should_behave_like 'an ActiveRecord-customized integer greater than 0'
    end
    
    it 'should not require a coverage' do
      @it.coverage = nil
      @it.should be_valid
    end
  end
end
