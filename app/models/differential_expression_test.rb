# == Schema Information
#
# Table name: differential_expression_tests
#
#  id               :integer          not null, primary key
#  sample1          :string(255)      not null
#  sample2          :string(255)      not null
#  test_status_name :string(255)      not null
#  FPKMx            :decimal(, )      not null
#  FPKMy            :decimal(, )      not null
#  log2_y_over_x    :decimal(, )      not null
#  test_stat        :decimal(, )      not null
#  p_value          :decimal(, )      not null
#  q_value          :decimal(, )      not null
#  significant?     :boolean          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class DifferentialExpressionTest < ActiveRecord::Base
  attr_accessible :FPKMx, :FPKMy, :log2_y_over_x, :p_value, :q_value, :sample1, :sample2, :significant?, :test_stat, :test_status_name
  
  #Associations
  has_one :test_status
  has_one :gene
  has_one :transcript
  
  #Validations
  validates :id, :presence => true
  validates :sample1, :presence => true
  validates :sample2, :presence => true
  validates :test_status_name, :presence => true
  validates :FPKMx, :presence => true
  validates :FPKMy, :presence => true
  validates :log2_y_over_x, :presence => true
  validates :test_stat, :presence => true
  validates :p_value, :presence => true
  validates :q_value, :presence => true
  validates :significant?, :presence => true
end
