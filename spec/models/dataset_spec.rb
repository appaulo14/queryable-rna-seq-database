# == Schema Information
#
# Table name: datasets
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  has_transcript_diff_exp :boolean          not null
#  has_transcript_isoforms :boolean          not null
#  has_gene_diff_exp       :boolean          not null
#  blast_db_location       :string(255)      not null
#  user_id                 :integer          not null
#  when_last_queried       :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'spec_helper'

describe Dataset do
  before(:each) do
    @it = FactoryGirl.build(:dataset)
  end
  
  describe 'associations' do
    it 'should have a user attribute' do
      @it.should respond_to(:user)
    end
    
    it 'should have a genes attribute' do
      @it.should respond_to(:genes)
    end
    
    it 'should have a transcripts attribute' do
      @it.should respond_to(:transcripts)
    end
    
    it 'should have a samples attribute' do
      @it.should respond_to(:samples)
    end
  end
  
  describe 'validations' do
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
    
    it 'should require a user' do
      @it.user = nil
      @it.should_not be_valid
    end
    
    describe 'has_transcript_diff_exp' do
      it 'should not be valid for nils' do
        @it.has_transcript_diff_exp = nil
        @it.should_not be_valid
      end
      
      it 'should not be valid for empty strings' do
        @it.has_transcript_diff_exp = ''
        @it.should_not be_valid
      end
      
      it "should convert an assignment of 1 to true" do
        @it.has_transcript_diff_exp = false
        @it.has_transcript_diff_exp = 1
        @it.should be_true
      end
      
      it "should convert an assignment of '1' to true" do
        @it.has_transcript_diff_exp = false
        @it.has_transcript_diff_exp = '1'
        @it.should be_true
      end
      
      it "should convert an assignment of 'true' to true" do
        @it.has_transcript_diff_exp = false
        @it.has_transcript_diff_exp = 'true'
        @it.should be_true
      end
      
      it "should convert strings besides '1', 'true', and '' to false" do
        ["cat", "helloooo", "tru"].each do |value|
          @it..has_transcript_diff_exp = true
          @it.has_transcript_diff_exp = value
          @it.has_transcript_diff_exp.should be_false
        end
      end
      
      it 'should convert empty arrays to false' do
        @it.has_transcript_diff_exp = true
        @it.has_transcript_diff_exp = []
        @it.has_transcript_diff_exp.should be_false
      end
      
      it 'should convert empty hashes to false' do
        @it.has_transcript_diff_exp = true
        @it.has_transcript_diff_exp = {}
        @it.has_transcript_diff_exp.should be_false
      end
      
      it 'should convert random objects to false' do
        @it.has_transcript_diff_exp = true
        @it.has_transcript_diff_exp = Object.new
        @it.has_transcript_diff_exp.should be_false
      end
      
      it 'should convert numbers besides 1 to false' do
        [45, -4.5, 0,1000000].each do |value|
          @it.has_transcript_diff_exp = value
          @it.has_transcript_diff_exp.to_s.should eq('false')
        end
      end
      
      it 'should prevent non-boolean values from being assigned to it' do
#         @it.has_transcript_diff_exp = true
#         ["cat","", 45, [], 1].each do |x|
#           @it.has_transcript_diff_exp = x
#           puts "=#{@it.has_transcript_diff_exp.to_s}"
#           debugger
#           @it.has_transcript_diff_exp.to_s.should eq('false')
#         end
      end
      
      it 'should be valid for true' do
        @it.has_transcript_diff_exp = true
        @it.should be_valid
      end
      
      it 'should be valid for false' do
        @it.has_transcript_diff_exp = false
        @it.should be_valid
      end
      
    end
  end
end
