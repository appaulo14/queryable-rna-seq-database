# == Description
# 
# Represents a differential expression test for a gene or transcript. 
# In a differential expression test, the level of expression of a gene or 
# transcript is compared between two samples to see if the gene or transcript 
# is more highly expressed in one sample than the other. 
#
#
# == Schema Information
#
# Table name: differential_expression_tests
#
#  id                   :integer          not null, primary key
#  gene_id              :integer
#  transcript_id        :integer
#  sample_comparison_id :integer          not null
#  test_status          :string(255)
#  sample_1_fpkm        :string(255)
#  sample_2_fpkm        :string(255)
#  log_fold_change      :string(255)      not null
#  test_statistic       :string(255)
#  p_value              :string(255)      not null
#  fdr                  :string(255)      not null
#

class DifferentialExpressionTest < ActiveRecord::Base
  attr_accessible  :gene, :transcript, :sample_comparison, :test_status,
                   :sample_1_fpkm, :sample_2_fpkm, :log_fold_change,
                   :test_statistic, :p_value, :fdr
  
  # The available valid values for the test status
  POSSIBLE_TEST_STATUSES = ['OK','NOTEST','LOWDATA','HIDATA','FAIL']
  
  belongs_to :gene
  belongs_to :transcript
  belongs_to :sample_comparison
  
  validate  :should_not_have_both_gene_and_transcript
  
  validates :sample_comparison, :presence => true
  
  validates :test_status, :allow_nil => true,
                          :inclusion => { :in => POSSIBLE_TEST_STATUSES }
  
  validates :sample_1_fpkm, :allow_nil => true,
                            :numericality => true
  
  validates :sample_2_fpkm, :allow_nil => true,
                            :numericality => true
  
  validates :log_fold_change, :presence => true,
                              :numericality => true
  validates  :test_statistic, :allow_nil => true,
                              :numericality => true 
  validates :p_value, :presence => true,
                      :numericality => true
  validates :fdr, :presence => true,
                  :numericality => true

  private 
  
  def should_not_have_both_gene_and_transcript
    if not gene.nil? and not transcript.nil?
      errors[:base] << 'can only have either a gene or transcript, not both'
    end
  end
end
