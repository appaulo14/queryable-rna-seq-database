# == Schema Information
#
# Table name: transcripts
#
#  id                              :integer          not null, primary key
#  differential_expression_test_id :integer          not null
#  job_id                          :integer          not null
#  gene_id                         :integer          not null
#  sequence                        :text             not null
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
    
    @transcript = Transcript.new(@attr)
    @fpkm_samples = []
      @fpkm_samples << Factory(:fpkm_sample, :sample_number => 1, :transcript => @transcript)
      @fpkm_samples << Factory(:fpkm_sample, :sample_number => 2, :transcript => @transcript)
    @transcript.fpkm_samples = @fpkm_samples
  end
  
  it "should create a new instances when given valid attributes" do
      @transcript.save!
  end
  
  it "should require a differential expression test id" do
      @attr[:differential_expression_test]=nil
      Transcript.new(@attr).should_not be_valid
  end
  
  it "should respond to differential_expression_test"
  
  
  it "should require the associated differential_expression_test be valid"
  
  it "should require a job id" 
  
  it "should enforce referential integrity for " +
          "the job id" 
  
  it "should respond to job"
  
  it "should require the associated job be valid"
  
  it "should require a gene id" 
  
  it "should enforce referential integrity for " +
          "the gene id"
  
  it "should respond to gene"
  
  it "should require the associated gene be valid"
  
  it "should require a sequence" 
  
  it "should require a sequence in fasta format" 
  
  it "should require a name from the program (ex. cufflinks)"
  
  it "should respond to fpkm_samples"
  
  it "should destroy any dependents from fpkm_samples"
  
  it "should require the associated fpkm_samples be valid"
end
