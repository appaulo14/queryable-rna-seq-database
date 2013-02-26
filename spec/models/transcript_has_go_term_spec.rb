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
#     @it = TranscriptHasGoTerm.new()
#     transcript = Transcript.new()
#     transcript.id = 1
#     go_term = GoTerm.new()
#     go_term.id = 'GO:00001'
#     @it.transcript = transcript
#     @it.go_term = go_term
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
    
    describe 'transcript' do
      it 'should require a transcript id' do
        [nil, ''].each do |invalid_transcript_id|
          @it.transcript_id = invalid_transcript_id
          @it.should_not be_valid
        end
      end
      it 'should be invalid when the transcript id is not an ' +
         'integer greater than 0' do
        [-1, 0, 3.6, 'a', '3.5'].each do |invalid_transcript_id|
          @it.transcript_id = invalid_transcript_id
          @it.should_not be_valid
        end
      end
      
      it 'should be valid for transcript ids that are integers greater ' +
         'than 0' do
        [1,  400, 10000, 104353].each do |valid_transcript_id|
          @it.transcript_id = valid_transcript_id
          puts @it.errors.full_messages if not @it.valid?
          @it.should be_valid
        end
      end
      
      it 'should require a transcript' do
        @it.transcript = nil
        @it.should_not be_valid
      end
    end
    describe 'go term' do
      it 'should require a go term id' do
        [nil, ''].each do |absent_go_term_id|
          @it.go_term_id = absent_go_term_id
          @it.should_not be_valid
        end
      end
      it 'should require a go term id to be in the correct format' do
        ['kittens','GX:0001','G0:0001'].each do |invalid_go_term_id|
          @it.id = invalid_go_term_id
          @it.should_not be_valid
        end
      end
      it 'should require a go term' do
        @it.go_term = nil
        @it.should_not be_valid
      end
    end
  end
end
