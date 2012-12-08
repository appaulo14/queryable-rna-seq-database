# == Schema Information
#
# Table name: differential_expression_tests
#
#  id               :integer          not null, primary key
#  fpkm_sample_1_id :integer          not null
#  fpkm_sample_2_id :integer          not null
#  gene_id          :integer
#  transcript_id    :integer
#  test_status      :string(255)
#  log_fold_change  :decimal(, )
#  p_value          :decimal(, )      not null
#  q_value          :decimal(, )      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class DifferentialExpressionTest < ActiveRecord::Base
  attr_accessible  :log_fold_change, :p_value, :q_value, :fpkm_sample_1, 
                   :fpkm_sample_2, :test_status, :transcript, :gene
  
  POSSIBLE_TEST_STATUSES = ['NOTEST','LOWDATA','HIDATA','FAIL']
  
  #Associations
  #has_one :test_status, :foreign_key => :name
  belongs_to :gene
  belongs_to :transcript
  belongs_to :fpkm_sample_1, :class_name => 'FpkmSample'
  belongs_to :fpkm_sample_2, :class_name => 'FpkmSample'
  
  #Validations
#   validates :sample1, :presence => true
#   validates :sample2, :presence => true
#   validates :test_status_name, :presence => true,
#           :inclusion => { :in => %w(OK LOWDATA HIDATA FAIL) }
#   validates :fpkm_x, :presence => true,
#           :numericality => { :only_double => true }
#   validates :fpkm_y, :presence => true,
#           :numericality => { :only_double => true }
#   validates :log2_y_over_x, :presence => true,
#           :numericality => { :only_double => true }
#   validates :test_stat, :presence => true,
#           :numericality => { :only_double => true }
#   validates :p_value, :presence => true,
#           :numericality => { :only_double => true }
#   validates :q_value, :presence => true,
#           :numericality => { :only_double => true }
#   validates :is_significant, :presence => true,
#           :inclusion => { :in => [true, false] }
end
