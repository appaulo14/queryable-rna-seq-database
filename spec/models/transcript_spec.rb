# == Schema Information
#
# Table name: transcripts
#
#  id                              :integer          not null, primary key
#  differential_expression_test_id :integer          not null
#  job_id                          :integer          not null
#  gene_id                         :integer          not null
#  fasta_sequence                        :text             not null
#  name_from_program               :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'spec_helper'

describe Transcript do
  before(:each) do
      @job = Factory(:job)
      @differential_expression_test = Factory(:differential_expression_test)
      @gene = Factory(:gene, :job => @job, 
                      :differential_expression_test => @differential_expression_test)
      
    @attr = {
      :differential_expression_test => @differential_expression_test,
      :job  => @job,
      :gene => @gene,
      :sequence => "ATKMBVCNSWD-GUYRHatkmbvcnswd-guyrh",
      :name_from_program => "TCONS_00001",
    }
  end
  
  it "should create a new instances when given valid attributes" do
      Transcript.create!(@attr)
  end
  
  it "should require a unique id"
  
  it "should require a differential expression test" do
      @attr[:differential_expression_test]=nil
      Transcript.new(@attr).should_not be_valid
  end
  
  it "should respond to differential_expression_test" do
    Transcript.create!(@attr).should respond_to(:differential_expression_test)
  end
  
  
  it "should require the associated differential_expression_test be valid" do
      @attr[:differential_expression_test].p_value = "INVALID_P_VALUE"
      Transcript.new(@attr).should_not be_valid
  end
  
  it "should require a job" do
      @attr[:job]=nil
      Transcript.new(@attr).should_not be_valid
  end
  
  it "should required the associated job to be valid" do
       @attr[:job].eid_of_owner = nil
      Transcript.new(@attr).should_not be_valid
  end
  
  it "should respond to job" do
    Transcript.create!(@attr).should respond_to(:job)
  end
  
  it "should require a gene" do
       @attr[:gene]=nil
      Transcript.new(@attr).should_not be_valid
  end
  
  it "should require the associated gene to be valid"
  
  it "should respond to gene" do
      Transcript.create!(@attr).should respond_to(:gene)
  end
  
  it "should require a fasta sequence" 
  
  it "should require a fasta sequence in fasta format" 
  
  it "should require a name from the program (ex. cufflinks)"
  
  describe "relationship with fpkm_samples" do
  
    it "should respond to fpkm_samples" do
        Transcript.create!(@attr).should respond_to(:fpkm_samples)
    end
    
    it "should destroy any dependents from fpkm_samples" do
        transcript = Transcript.create!(@attr)
        transcript.fpkm_samples << Factory(:fpkm_sample, :sample_number => 1, :transcript => transcript)
        transcript.fpkm_samples << Factory(:fpkm_sample, :sample_number => 2, :transcript => transcript)
        transcript.save!
        transcript.destroy
        transcript.should be_destroyed
        transcript.fpkm_samples.each do |fpkm_sample|
            fpkm_sample.should be_destroyed
        end
    end
    
    it "should successfully create a new instance when " + 
       "fpkm samples are valid" do
        transcript = Transcript.create!(@attr)
        transcript.fpkm_samples << Factory(:fpkm_sample, :sample_number => 1, :transcript => transcript)
        transcript.fpkm_samples << Factory(:fpkm_sample, :sample_number => 2, :transcript => transcript)
        transcript.save!
    end
    
    it "should require the associated fpkm_samples be valid" do
        transcript = Transcript.create!(@attr)
        transcript.fpkm_samples << Factory(:fpkm_sample, :sample_number => 1, :transcript => transcript)
        transcript.fpkm_samples << Factory(:fpkm_sample, :sample_number => 2, :transcript => transcript)
        transcript.fpkm_samples[0].sample_number = "INVALID SAMPLE NUMBER"
        transcript.should_not be_valid
    end
  
  end
end
