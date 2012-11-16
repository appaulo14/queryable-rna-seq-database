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
      @gene = Factory(:gene, :job => @job, :differential_expression_test => @differential_expression_test)
      
    @attr = {
      :differential_expression_test => @differential_expression_test,
      :job  => @job,
      :gene => @gene,
      :sequence => "ATKMBVCNSWD-GUYRHatkmbvcnswd-guyrh",
      :name_from_program => "TCONS_00001"
    }
  end
  
  it "should create a new instances when given valid attributes" do
      Transcript.create!(@attr)
  end
  
  it "should require a differential expression test id" do
  end
  
  it "should enforce referential integrity for " +
          "differential expression test id" do
  end
  
  it "should require a job id" do
  end
  
  it "should enforce referential integrity for " +
          "the job id" do
  end
  
  it "should require a gene id" do
  end
  
  it "should enforce referential integrity for " +
          "the gene id" do
  end
  
  it "should require a sequence" do
  end
  
  it "should require a sequence in fasta format" do
  end
  
  it "should require a name from the program (ex. cufflinks)" do
  end
end
