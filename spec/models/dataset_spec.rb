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
  
  describe 'destruction' do
    before(:each) do 
      @it.save!
    end
    
    it 'should destroy all associated transcripts when destroyed' do
      FactoryGirl.create(:transcript, :dataset_id => @it.id)
      FactoryGirl.create(:transcript, :dataset_id => @it.id)
      Transcript.find_all_by_dataset_id(@it.id).count.should eq(2)
      @it.destroy
      Transcript.find_all_by_dataset_id(@it.id).should be_empty
    end
    it 'should destroy all associated genes when destroyed'
    it 'should destroy all associated samples when destroyed'
    it 'should not destroy the associated user when destroyed'
  end
  
  describe 'validations' do
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
    
    it 'should require a name' do
      [nil, ""].each do |invalid_value|
        @it.name = invalid_value
        @it.should_not be_valid
      end
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
      
      it "should convert string assignments " +
         "besides '1', 'true', and '' to false" do
        ["cat", "helloooo", "tru"].each do |value|
          @it.has_transcript_diff_exp = true
          @it.has_transcript_diff_exp = value
          @it.has_transcript_diff_exp.should be_false
        end
      end
      
      it 'should convert an empty array assignment to false' do
        @it.has_transcript_diff_exp = true
        @it.has_transcript_diff_exp = []
        @it.has_transcript_diff_exp.should be_false
      end
      
      it 'should convert an empty hash assignment to false' do
        @it.has_transcript_diff_exp = true
        @it.has_transcript_diff_exp = {}
        @it.has_transcript_diff_exp.should be_false
      end
      
      it 'should convert a random object assignment to false' do
        @it.has_transcript_diff_exp = true
        @it.has_transcript_diff_exp = Object.new
        @it.has_transcript_diff_exp.should be_false
      end
      
      it 'should convert number assigments besides 1 to false' do
        [45, -4.5, 0,1000000].each do |value|
          @it.has_transcript_diff_exp = value
          @it.has_transcript_diff_exp.to_s.should eq('false')
        end
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
    
     describe 'has_transcript_isoforms' do
      it 'should not be valid for nils' do
        @it.has_transcript_isoforms = nil
        @it.should_not be_valid
      end
      
      it 'should not be valid for empty strings' do
        @it.has_transcript_isoforms = ''
        @it.should_not be_valid
      end
      
      it "should convert an assignment of 1 to true" do
        @it.has_transcript_isoforms = false
        @it.has_transcript_isoforms = 1
        @it.should be_true
      end
      
      it "should convert an assignment of '1' to true" do
        @it.has_transcript_isoforms = false
        @it.has_transcript_isoforms = '1'
        @it.should be_true
      end
      
      it "should convert an assignment of 'true' to true" do
        @it.has_transcript_isoforms = false
        @it.has_transcript_isoforms = 'true'
        @it.should be_true
      end
      
      it "should convert string assignments besides " +
         "'1', 'true', and '' to false" do
        ["cat", "helloooo", "tru"].each do |value|
          @it.has_transcript_isoforms = true
          @it.has_transcript_isoforms = value
          @it.has_transcript_isoforms.should be_false
        end
      end
      
      it 'should convert an empty array assignment to false' do
        @it.has_transcript_isoforms = true
        @it.has_transcript_isoforms = []
        @it.has_transcript_isoforms.should be_false
      end
      
      it 'should convert an empty hash assignment to false' do
        @it.has_transcript_isoforms = true
        @it.has_transcript_isoforms = {}
        @it.has_transcript_isoforms.should be_false
      end
      
      it 'should convert a random object assignment to false' do
        @it.has_transcript_isoforms = true
        @it.has_transcript_isoforms = Object.new
        @it.has_transcript_isoforms.should be_false
      end
      
      it 'should convert number assignments besides 1 to false' do
        [45, -4.5, 0,1000000].each do |value|
          @it.has_transcript_isoforms = value
          @it.has_transcript_isoforms.to_s.should eq('false')
        end
      end
      
      it 'should be valid for true' do
        @it.has_transcript_isoforms = true
        @it.should be_valid
      end
      
      it 'should be valid for false' do
        @it.has_transcript_isoforms = false
        @it.should be_valid
      end
    end
    
     describe 'has_gene_diff_exp' do
      it 'should not be valid for nils' do
        @it.has_gene_diff_exp = nil
        @it.should_not be_valid
      end
      
      it 'should not be valid for empty strings' do
        @it.has_gene_diff_exp = ''
        @it.should_not be_valid
      end
      
      it "should convert an assignment of 1 to true" do
        @it.has_gene_diff_exp = false
        @it.has_gene_diff_exp = 1
        @it.should be_true
      end
      
      it "should convert an assignment of '1' to true" do
        @it.has_gene_diff_exp = false
        @it.has_gene_diff_exp = '1'
        @it.should be_true
      end
      
      it "should convert an assignment of 'true' to true" do
        @it.has_gene_diff_exp = false
        @it.has_gene_diff_exp = 'true'
        @it.should be_true
      end
      
      it "should convert string assignments besides " +
         "'1', 'true', and '' to false" do
        ["cat", "helloooo", "tru"].each do |value|
          @it.has_gene_diff_exp = true
          @it.has_gene_diff_exp = value
          @it.has_gene_diff_exp.should be_false
        end
      end
      
      it 'should convert an empty array assignment to false' do
        @it.has_gene_diff_exp = true
        @it.has_gene_diff_exp = []
        @it.has_gene_diff_exp.should be_false
      end
      
      it 'should convert an empty hash assignment to false' do
        @it.has_gene_diff_exp = true
        @it.has_gene_diff_exp = {}
        @it.has_gene_diff_exp.should be_false
      end
      
      it 'should convert a random object assignment to false' do
        @it.has_gene_diff_exp = true
        @it.has_gene_diff_exp = Object.new
        @it.has_gene_diff_exp.should be_false
      end
      
      it 'should convert number assignments besides 1 to false' do
        [45, -4.5, 0,1000000].each do |value|
          @it.has_gene_diff_exp = value
          @it.has_gene_diff_exp.to_s.should eq('false')
        end
      end
      
      it 'should be valid for true' do
        @it.has_gene_diff_exp = true
        @it.should be_valid
      end
      
      it 'should be valid for false' do
        @it.has_gene_diff_exp = false
        @it.should be_valid
      end
    end
    
    describe 'blast_db_location' do
      it 'should not be valid when nil' do
        @it.blast_db_location = nil
        @it.should_not be_valid
      end
      
      it 'should not be valid when empty' do
        @it.blast_db_location = ""
        @it.should_not be_valid
      end
      
      it 'should not be valid for an invalid pathname' do
        @it.blast_db_location = "/invalid/path\0name"
        @it.should_not be_valid
      end
      
      it 'should be valid for valid a valid patname' do
        ['/tmp/db_1','db_1'].each do |valid_pathname|
          @it.blast_db_location = valid_pathname
          @it.should be_valid
        end
      end
    end
    
    it 'should require a user' do
      @it.user = nil
      @it.should_not be_valid
    end
    
    describe 'when_last_queried' do
      it 'should be valid for nils' do
        @it.when_last_queried = nil
        @it.should be_valid
      end
      
      it 'should be valid for a valid DateTime object' do
        @it.when_last_queried = DateTime.now
        @it.should be_valid
      end
      
      it 'should be valid for a valid Time object' do
        @it.when_last_queried = Time.now
        @it.should be_valid
      end
      
      it "should convert string assignments to nil" do
        ["cat", "helloooo", "tru", ""].each do |value|
          @it.when_last_queried = value
          @it.when_last_queried.should be_nil
        end
      end
      
      it 'should not be valid for empty arrays' do
        @it.when_last_queried = []
        @it.should_not be_valid
      end
      
      it 'should not be valid for empty hashes' do
        @it.when_last_queried = {}
        @it.should_not be_valid
      end
      
      it 'should not be valid for random objects' do
        @it.when_last_queried = Object.new
        @it.should_not be_valid
      end
      
      it 'should not be valid for numbers' do
        [45, -4.5, 0,1000000].each do |value|
          #A new dataset is created each time here because of a strange 
          #     behavior where assignment no longer works after the 
          #     firt assignment to when_last_queried
          @it =  FactoryGirl.build(:dataset)
          @it.when_last_queried = value
          @it.should_not be_valid
        end
      end
    end
  end
end
