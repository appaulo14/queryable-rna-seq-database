# == Schema Information
#
# Table name: datasets
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  progam_used             :string(255)      not null
#  has_transcript_diff_exp :boolean          not null
#  has_transcript_isoforms :boolean          not null
#  has_gene_diff_exp       :boolean          not null
#  blast_db_location       :string(255)      not null
#  user_id                 :integer          not null
#  when_last_queried       :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

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
    @it = FactoryGirl.build(:dataset, :program_used => :cuffdiff)
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
  
  describe 'when destroyed' do
    before(:each) do 
      @it.save!
    end
    
    it 'should destroy all associated transcripts' do
      FactoryGirl.create(:transcript, :dataset_id => @it.id)
      FactoryGirl.create(:transcript, :dataset_id => @it.id)
      Transcript.find_all_by_dataset_id(@it.id).count.should eq(2)
      @it.destroy
      Transcript.find_all_by_dataset_id(@it.id).should be_empty
    end
    
    it 'should destroy all associated genes' do
      FactoryGirl.create(:gene, :dataset_id => @it.id)
      FactoryGirl.create(:gene, :dataset_id => @it.id)
      Gene.find_all_by_dataset_id(@it.id).count.should eq(2)
      @it.destroy
      Gene.find_all_by_dataset_id(@it.id).should be_empty
    end
    
    it 'should destroy all associated samples' do
      FactoryGirl.create(:sample, :dataset_id => @it.id)
      FactoryGirl.create(:sample, :dataset_id => @it.id)
      Sample.find_all_by_dataset_id(@it.id).count.should eq(2)
      @it.destroy
      Sample.find_all_by_dataset_id(@it.id).should be_empty
    end
    
    it 'should not destroy the associated user' do
      @it.destroy
      User.find(@it.user_id).should_not be_nil
    end
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
    
#     shared_examples_for "goat" do
#       let(:goat) { FactoryGirl.build(:dataset) }
#       it 'should goat' do
#         puts "Type = #{ goat.has_gene_diff_exp.class}"
#         goat.has_gene_diff_exp.should be_true
#       end
#     end
#     
#     shared_examples_for "a measurable object" do |measurement, measurement_methods|
#       measurement_methods.each do |measurement_method|
#         it "should return #{measurement} from #{measurement_method}" do
#           subject.send(measurement_method).should == measurement
#         end
#       end
#     end
# 
#     describe Array, "with 3 items" do
#       subject { [1, 2, 3] }
#       it_should_behave_like "a measurable object", 3, [:size, :length]
#     end
# 
#     describe String, "of 6 characters" do
#       subject { "FooBar" }
#       it_should_behave_like "a measurable object", 6, [:size, :length]
#     end
    
    describe 'has_transcript_diff_exp' do
      #it_behaves_like 'goat'
      
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
          @it.has_transcript_diff_exp.should be_false
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
       #it_behaves_like 'goat'
       
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
          @it.has_transcript_isoforms.should be_false
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
          @it.has_gene_diff_exp.should be_false
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
          #A new dataset is created each time for this test because of a strange 
          #     behavior where assignment no longer works after the 
          #     firt assignment to when_last_queried
          @it = FactoryGirl.build(:dataset)
          @it.when_last_queried = value
          @it.should_not be_valid
        end
      end
    end
    
    describe 'program_used' do 
      it 'should be valid for :trinity_with_edger' do
        @it.program_used = :trinity_with_edger
        @it.should be_valid
      end
      it 'should be valid for :cuffdiff' do
        @it.program_used = :cuffdiff
        @it.should be_valid
      end
      
      it 'should not be valid for other strings' do
        ['puppies',''].each do |invalid_string|
          @it.program_used = invalid_string
          @it.should_not be_valid
        end
      end
      
      it 'should not be valid for numeric values' do
        [45,0,4.5, -42].each do |invalid_string|
          @it.program_used = invalid_string
          @it.should_not be_valid
        end
      end
      
      it 'should not be valid for boolean values' do
        [0,1,true,false].each do |invalid_string|
          @it.program_used = invalid_string
          @it.should_not be_valid
        end
      end
      
      it 'should not be valid for nil' do
        @it.program_used = nil
        @it.should_not be_valid
      end 
    end 
  end
end
