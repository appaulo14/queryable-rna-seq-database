# == Schema Information
#
# Table name: transcripts
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  gene_id           :integer
#  name_from_program :string(255)      not null
#


require 'spec_helper'

describe Transcript do
  before(:each) do
    @transcript = FactoryGirl.build(:transcript)
  end

  it "should create a new instances when given valid attributes" do
    @transcript.save!
  end

  it "should require a unique id" do
    @transcript.save!
    transcript2 = FactoryGirl.build(:transcript)
    transcript2.id = @transcript.id
    transcript2.should_not be_valid
  end
  
  it "should require a fasta sequence"  do
    @transcript.fasta_sequence = nil
    @transcript.should_not be_valid
  end

  it "should require a fasta sequence in fasta format" do
    @transcript.fasta_sequence = "INVALID FASTA SEQUENCE"
    @transcript.should_not be_valid
  end

  it "should require a name from the program (ex. cufflinks)" do
    @transcript.name_from_program = nil
    @transcript.should_not be_valid
  end
  
  
  describe "relationship with a differential expression test" do
    it "should require a differential expression test" do
      @transcript.differential_expression_test = nil
      @transcript.should_not be_valid
    end

    it "should respond to differential_expression_test" do
      @transcript.should respond_to(:differential_expression_test)
    end


    it "should be invalid if the associated differential_expression_test " +
       "is invalid" do
      @transcript.differential_expression_test =
      FactoryGirl.build(:invalid_differential_expression_test)
      @transcript.should_not be_valid
    end
    
    it "should destroy its differential expression test when it is destroyed" do
      @transcript.save!
      @transcript.destroy
      @transcript.differential_expression_test.should be_destroyed
    end
  end

  
  describe "relationship with a job" do
    it "should require a job" do
      @transcript.job = nil
      @transcript.should_not be_valid
    end

    it "should be invalid if the associated job is invalid" do
      @transcript.job =
        FactoryGirl.build(:invalid_job)
      @transcript.should_not be_valid
    end

    it "should respond to job" do
      @transcript.should respond_to(:job)
    end
  end

  
  describe "relationship with genes" do
    it "should not require a gene" do
      @transcript.gene = nil
      @transcript.should be_valid
    end

    it "should be invalid if the associated gene is invalid" do
      @transcript.gene =
        FactoryGirl.build(:invalid_gene)
      @transcript.should_not be_valid
    end

    it "should respond to gene" do
      @transcript.should respond_to(:gene)
    end
    
    it "should be invalid when the gene has a different job than it" do
      @transcript.gene.job = FactoryGirl.create(:job)
      @transcript.should_not be_valid
    end
  end

  
  describe "relationship with fpkm_samples" do
    it "should respond to fpkm_samples" do
      @transcript.should respond_to(:fpkm_samples)
    end

    it "should destroy any dependents from fpkm_samples when it is destroyed" do
      @transcript.fpkm_samples << FactoryGirl.build(:fpkm_sample,
                                                    :sample_number => 1,
                                                    :transcript => @transcript)
      @transcript.fpkm_samples << FactoryGirl.build(:fpkm_sample,
                                                    :sample_number => 2,
                                                    :transcript => @transcript)
      @transcript.save!
      @transcript.destroy
      @transcript.fpkm_samples.each do |fpkm_sample|
        fpkm_sample.should be_destroyed
      end
    end

    it "should successfully create a new instance when " +
       "fpkm samples are valid" do
      @transcript.fpkm_samples << FactoryGirl.build(:fpkm_sample,
                                                    :sample_number => 1,
                                                    :transcript => @transcript)
      @transcript.fpkm_samples << FactoryGirl.build(:fpkm_sample,
                                                    :sample_number => 2,
                                                    :transcript => @transcript)
      @transcript.save!
    end

    it "should be invalid when the fpkm_samples are invalid" do
      @transcript.fpkm_samples << FactoryGirl.build(:invalid_fpkm_sample,
                                                    :sample_number => 1,
                                                    :transcript => @transcript)
      @transcript.fpkm_samples << FactoryGirl.build(:invalid_fpkm_sample,
                                                    :sample_number => 2,
                                                    :transcript => @transcript)
      @transcript.should_not be_valid
    end
  end
end
