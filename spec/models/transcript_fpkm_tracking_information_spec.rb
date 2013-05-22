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
  
  describe 'assocations', :type => :associations do
    it 'should have a transcript attribute' do
      @it.should respond_to(:transcript)
    end
  end
  
  describe 'when deleted', :type => :when_deleted do
    before (:each) do @it.save! end
  
    it 'should not delete the associated transcript' do
      associated_transcript = @it.transcript
      @it.delete()
      Transcript.find(associated_transcript.id).should_not be_nil
    end
  end
  
  describe 'validations' do
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
    
    describe 'transcript' do
      before(:each) do @attribute = 'transcript' end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'class code' do
      before(:each) do @attribute = 'class_code' end
      
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
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'length' do
      before(:each) do @attribute = 'length' end

      it_should_behave_like 'a required attribute'  
      it_should_behave_like 'an ActiveRecord-customized integer >= 0'
    end
    
    describe 'coverage' do
      before(:each) do @attribute = 'coverage' end
      
      it_should_behave_like 'an optional attribute'
    end
  end
end
