# == Schema Information
#
# Table name: go_terms
#
#  id   :string(255)      not null, primary key
#  term :string(255)      not null
#

require 'spec_helper'
require 'models/shared_examples.rb'

describe GoTerm do
  before (:each) do
    @it = FactoryGirl.build(:go_term)
  end
  
  describe 'associations', :type => :associations do
    it 'should have a transcripts attribute' do
      @it.should respond_to(:transcripts)
    end
  
    it 'should have a transcript_has_go_terms attribute' do
      @it.should respond_to(:transcript_has_go_terms)
    end
  end
  
  describe 'when destroyed', :type => :when_destroyed do
    before (:each) do @it.save! end
    
    it 'should destroy any associated transcript_has_go_terms' do
      FactoryGirl.create(:transcript_has_go_term, :go_term => @it)
      FactoryGirl.create(:transcript_has_go_term, :go_term => @it)
      TranscriptHasGoTerm.find_all_by_go_term_id(@it.id).count.should eq(2)
      @it.destroy
      TranscriptHasGoTerm.find_all_by_go_term_id(@it.id).should be_empty
    end
    
    it 'should not destroy any associated transcripts' do
      @it.transcripts << FactoryGirl.create(:transcript)
      @it.transcripts << FactoryGirl.create(:transcript)
      @it.save!
      associated_transcripts = GoTerm.find(@it.id).transcripts
      associated_transcripts.count.should eq(2)
      @it.destroy
      associated_transcripts.each do |associated_transcript|
        Transcript.find(associated_transcript.id).should_not be_nil
      end
    end
  end
  
  describe 'validations', :type => :validations do    
    it 'should save successfully when all fields are valid' do
      @it.save!
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
    
    describe 'id' do
      before(:each) do @attribute = 'id' end
    
      it_should_behave_like 'a required attribute'
      
      it 'should require an id to be in the correct format' do
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
    end
    
    describe 'term' do
      before(:each) do @attribute = 'term' end
    
      it_should_behave_like 'a required attribute'
    end
  end
end
