# == Schema Information
#
# Table name: transcript_fpkm_tracking_informations
#
#  transcript_id :integer          not null, primary key
#  class_code    :string(255)      not null
#  length        :integer          not null
#  coverage      :string(255)
#

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

describe TranscriptFpkmTrackingInformation do
  before(:each) do
    @it = FactoryGirl.build(:transcript_fpkm_tracking_information)
  end
  
  describe 'assocations' do
    it 'should have a transcript attribute' do
      @it.should respond_to(:transcript)
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
    it 'should requie a class code'
    it 'should require a length'
    it 'should require a few other things'
    it 'should not require a coverage'
  end
end
