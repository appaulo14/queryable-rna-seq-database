# == Schema Information
#
# Table name: go_terms
#
#  id   :string(255)      not null, primary key
#  term :string(255)      not null
#

require 'spec_helper'

describe GoTerm do
  before (:each) do
    @it = FactoryGirl.build(:go_term)
  end
  
  describe 'associations' do
    it 'should have a transcripts attribute' do
      @it.should respond_to(:transcripts)
    end
  
    it 'should have a transcript_has_go_terms attribute' do
      @it.should respond_to(:transcript_has_go_terms)
    end
  end
  
  describe 'validations' do
    it 'should be valid when all fields are valid' do
     @it.should be_valid
    end
    
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
  
    it 'should require a go id' do
      [nil, ''].each do |invalid_value|
        @it.id = invalid_value
        @it.should_not be_valid
      end
    end
    
    it 'should require a go term' do
      [nil, ''].each do |absent_term|
        @it.term = absent_term
        @it.should_not be_valid
      end
    end
    
    it 'should require a go id to be in the correct format' do
      ['kittens','GX:0001','G0:0001'].each do |invalid_id|
        @it.id = invalid_id
        @it.should_not be_valid
      end
    end
    
    it 'should be valid for go ids that are in the correct format' do
      ['GO:0001','GO:00055','GO:100001'].each do |valid_id|
        @it.id = valid_id
        @it.should be_valid
      end
    end
    
    it 'should correctly validate all the go terms from the go website' do
        go_term_file = File.open('lib/tasks/GO.terms_and_ids')
        #Loop through all the go terms downloaded from the go web site
        while (not go_term_file.eof?)
          #Extract the go term and go id
          line = go_term_file.readline
          next if line.match(/\AGO/).nil? #skip if line has no term 
          go_id, go_term = line.split(/\t/)
          #Confirm that the go term and id are correctly validated
          go_term = GoTerm.new(:id => go_id, :term => go_term)
          go_term.should be_valid
        end
    end
  end
  
end
