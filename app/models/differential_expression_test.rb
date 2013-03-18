# == Schema Information
#
# Table name: differential_expression_tests
#
#  id                   :integer          not null, primary key
#  gene_id              :integer
#  transcript_id        :integer
#  sample_comparison_id :integer          not null
#  test_status          :string(255)
#  sample_1_fpkm        :string(255)      not null
#  sample_2_fpkm        :string(255)      not null
#  log_fold_change      :string(255)      not null
#  test_statistic       :string(255)
#  p_value              :string(255)      not null
#  fdr                  :string(255)      not null
#

class DifferentialExpressionTest < ActiveRecord::Base
  attr_accessible  :gene, :transcript, :sample_comparison, :test_status,
                   :sample_1_fpkm, :sample_2_fpkm, :log_fold_change,
                   :test_statistic, :p_value, :fdr
  
  POSSIBLE_TEST_STATUSES = ['OK','NOTEST','LOWDATA','HIDATA','FAIL']
  
  belongs_to :gene
  belongs_to :transcript
  belongs_to :sample_comparison
  
  validate  :should_not_have_both_gene_and_transcript
  
  validates :sample_comparison, :presence => true
  
  validates :test_status, :allow_nil => true,
                          :inclusion => { :in => POSSIBLE_TEST_STATUSES }
  
  validates :sample_1_fpkm, :presence => true
  validate  :sample_1_fpkm_is_greater_than_or_equal_to_zero
  
  validates :sample_2_fpkm, :presence => true
  validate  :sample_2_fpkm_is_greater_than_or_equal_to_zero
  
  validates :log_fold_change, :presence => true
  validate  :log_fold_change_is_greater_than_or_equal_to_zero
  
  validate  :test_statistic_is_greater_than_or_equal_to_zero
  
  validates :p_value, :presence => true
  validate  :p_value_is_greater_than_or_equal_to_zero
  
  validates :fdr, :presence => true
  validate  :fdr_is_greater_than_or_equal_to_zero


  private 
  
  def should_not_have_both_gene_and_transcript
    if not gene.nil? and not transcript.nil?
      errors[:base] << 'can only have either a gene or transcript, not both'
    end
  end
  
  def sample_1_fpkm_is_greater_than_or_equal_to_zero
    is_greater_than_or_equal_to_zero('sample_1_fpkm')
  end
  
  def sample_2_fpkm_is_greater_than_or_equal_to_zero
    is_greater_than_or_equal_to_zero('sample_2_fpkm')
  end
  
  def log_fold_change_is_greater_than_or_equal_to_zero
    is_greater_than_or_equal_to_zero('log_fold_change')
  end
  
  def test_statistic_is_greater_than_or_equal_to_zero
    is_greater_than_or_equal_to_zero('test_statistic')
  end
  
  def p_value_is_greater_than_or_equal_to_zero
    is_greater_than_or_equal_to_zero('p_value')
  end
  
  def fdr_is_greater_than_or_equal_to_zero
    is_greater_than_or_equal_to_zero('fdr')
  end
  
  def is_greater_than_or_equal_to_zero(attribute)
    return if self.send(attribute).nil?
    begin
      if self.send(attribute).to_f < 0.0
        errors[attribute] << 'must be greater than or equal to zero'
      end
    rescue NoMethodError => ex
      errors[attribute] << 'must be float or double'
    end
  end
end
