# == Schema Information
#
# Table name: transcript_has_go_terms
#
#  transcript_id :integer          not null
#  go_term_id    :string(255)      not null
#


require 'spec_helper'
require 'models/shared_examples.rb'

describe TranscriptHasGoTerm do
  before (:each) do
    @it = FactoryGirl.build(:transcript_has_go_term)
  end
  
  describe 'associations', :type => :associations do
    it 'should respond to transcript' do
      @it.should respond_to(:transcript)
    end
    
    it 'should respond to go_term' do
      @it.should respond_to(:go_term)
    end
  end
  
  describe 'when deleted', :type => :when_deleted do
    before (:each) do @it.save! end
    
    it 'should not delete the associated transcript' do
      @it.delete()
      Transcript.find(@it.transcript.id).should_not be_nil
    end
    it 'should not delete the associated go term' do
      @it.delete()
      GoTerm.find(@it.go_term.id).should_not be_nil
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

    describe 'go_term' do
      before(:each) do @attribute = 'go_term' end
      
      it_should_behave_like 'a required attribute'
    end
  end
end
