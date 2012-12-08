# == Schema Information
#
# Table name: genes
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  name_from_program :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe Gene do
  
  before(:each) do
    @gene = FactoryGirl.build(:gene)
  end
  
  it "should create a new instances when given valid attributes"

  it "should require a unique id"
  
  it "should require a name from the program (ex. cufflinks)"
    
  describe "relationship with a differential expression test" do
    it "should require a differential expression test"

    it "should respond to differential_expression_test"

    it "should be invalid if the associated differential_expression_test " +
       "is invalid"
  end
  
  describe "relationship with transcripts" do
    it "should respond to transcripts"

    it "should be invalid if any associated trascripts are invalid"
  end
  
  describe "relationship with a job" do
    it "should require a job" do
      @gene.job = nil
      @gene.should_not be_valid
    end

    it "should be invalid if the associated job is invalid" do
      @gene.job = FactoryGirl.build(:invalid_job)
      @gene.should_not be_valid
    end

    it "should respond to job" do
      @gene.should respond_to(:job)
    end
  end
end
