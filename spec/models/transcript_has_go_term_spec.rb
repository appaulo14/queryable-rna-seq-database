# == Schema Information
#
# Table name: transcript_has_go_terms
#
#  transcript_id :integer          not null, primary key
#  go_term_id    :string(255)      not null
#


require 'spec_helper'

describe TranscriptHasGoTerm do
  before (:each) do
    @it = FactoryGirl.build(:transcript_has_go_term)
  end
  
  describe 'associations' do
    it 'should respond to transcript' do
      @it.should respond_to(:transcript)
    end
    
    it 'should respond to go_term' do
      @it.should respond_to(:go_term)
    end
  end
  describe 'validations' do
    it 'should be valid when all fields are valid' do
      @it.should be_valid
    end
    
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
      
    it 'should require a transcript' do
      @it.transcript = nil
      @it.should_not be_valid
    end

    it 'should require a go term' do
      @it.go_term = nil
      @it.should_not be_valid
    end
  end
end
