# == Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  current_job_status     :string(255)
#  current_program_status :string(255)
#  email                  :string(255)      not null
#  workflow_step_id       :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'spec_helper'

describe Job do
  before(:each) do
    @job = FactoryGirl.build(:job)
  end

  it "should create a new instances when given valid attributes" do
    @job.save!
  end
  
  it "should require a unique id" do
    @job.save!
    job2 = FactoryGirl.build(:job)
    job2.id = @job.id
    job2.should_not be_valid
  end
  
  it "should require the email of the job owner" do
    @job.email = nil
    @job.should_not be_valid
  end
  
  it "should require the email to be in valid email format"
  
  describe "relationship with genes" do
    it "should respond to genes" do
      @job.should respond_to(:genes)
    end
    
    it "should be invalid if an associated gene is invalid" do
      @job.genes << FactoryGirl.build(:invalid_gene)
      @job.genes << FactoryGirl.build(:invalid_gene)
      @job.should_not be_valid
    end
    
    it "should destroy all genes associated with it when it is destroyed" do
      @job.save!
      @job.destroy
      @job.genes.each do |gene|
        gene.should be_destroyed
      end
    end
  end
  
  
  describe "relationship with transcripts" do
    it "should respond to transcripts" do
      @job.should respond_to(:transcripts)
    end
    
    it "should destroy all transcripts associated with it when it is destroyed" do
      @job.save!
      @job.destroy
      @job.transcripts.each do |transcript|
        transcript.should be_destroyed
      end
    end
    
    it "should be invalid if an associated transcript is invalid" do
      @job.transcripts << FactoryGirl.build(:invalid_transcript)
      @job.transcripts << FactoryGirl.build(:invalid_transcript)
      @job.should_not be_valid
    end
  end
end
