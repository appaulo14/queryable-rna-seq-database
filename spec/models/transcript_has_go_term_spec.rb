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
    it 'should respond to transcript'
    
    it 'should respond to go_term'
  end
  describe 'validations' do
    it 'should be valid when all fields are valid' do
      @it.should be_valid
    end
    
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
    
    describe 'transcript' do
      it 'should require a transcript id'
      it 'should the transcript id to be an integer greater than 0'
      it 'should require a transcript'
    end
    describe 'go term' do
      it 'should require a go term id'
      it 'should require a go term id to be in the correct format'
      it 'should require a go term'
    end
  end
end
