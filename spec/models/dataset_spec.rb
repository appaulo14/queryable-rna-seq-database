# == Schema Information
#
# Table name: datasets
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  program_used            :string(255)      not null
#  has_transcript_diff_exp :boolean          not null
#  has_transcript_isoforms :boolean          not null
#  has_gene_diff_exp       :boolean          not null
#  finished_uploading      :boolean          not null
#  go_terms_status         :string(255)      not null
#  blast_db_location       :string(255)      not null
#  user_id                 :integer          not null
#  when_last_queried       :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'spec_helper'
require 'models/shared_examples.rb'

describe Dataset do
  before(:each) do
    @it = FactoryGirl.build(:dataset, :program_used => 'cuffdiff')
  end
  
  describe 'associations', :type => :associations do
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
  
  describe 'when destroyed', :type => :when_destroyed do
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
  
  describe 'validations', :type => :validations do
    it 'should save successfully when all fields are valid' do
      @it.save!
    end
    
    describe 'name' do
      before (:each) do @attribute = 'name' end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'has_transcript_diff_exp' do
      before (:each) do @attribute = 'has_transcript_diff_exp' end
   
      it_should_behave_like 'a required attribute' 
      it_should_behave_like 'an ActiveRecord-customized boolean'
    end
    
     describe 'has_transcript_isoforms' do
       before (:each) do @attribute = 'has_transcript_isoforms' end
  
       it_should_behave_like 'a required attribute'
       it_should_behave_like 'an ActiveRecord-customized boolean'
     end
    
     describe 'has_gene_diff_exp' do
       before (:each) do @attribute = 'has_gene_diff_exp' end
       
       it_should_behave_like 'a required attribute'
       it_should_behave_like 'an ActiveRecord-customized boolean'
     end
    
    describe 'blast_db_location' do
      before(:each) do @attribute = 'blast_db_location' end
      
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
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'user' do
      before(:each) do @attribute = 'user' end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'when_last_queried' do
      before(:each) do @attribute = 'when_last_queried' end
      
      it_should_behave_like 'an optional attribute'
      it_should_behave_like 'an ActiveRecord-customized datetime'
    end
    
    describe 'program_used' do 
      before(:each) do @attribute = 'program_used' end
    
      it 'should be valid for "trinity_with_edger"' do
        @it.program_used = 'trinity_with_edger'
        @it.should be_valid
      end
      it 'should be valid for "cuffdiff"' do
        @it.program_used = 'cuffdiff'
        @it.should be_valid
      end
      it 'should be valid for "generic_fasta_file"' do
        @it.program_used = 'generic_fasta_file'
        @it.should be_valid
      end
      
      it 'should not be valid for other strings' do
        ['puppies',''].each do |invalid_string|
          @it.program_used = invalid_string
          @it.should_not be_valid
        end
      end
      
      it_should_behave_like 'a required attribute'
    end 
  end
end
