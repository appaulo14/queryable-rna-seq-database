# == Schema Information
#
# Table name: differential_expression_tests
#
#  id               :integer          not null, primary key
#  sample1          :string(255)      not null
#  sample2          :string(255)      not null
#  test_status_name :string(255)      not null
#  fpkm_x           :decimal(, )      not null
#  fpkm_y           :decimal(, )      not null
#  log2_y_over_x    :decimal(, )      not null
#  test_stat        :decimal(, )      not null
#  p_value          :decimal(, )      not null
#  q_value          :decimal(, )      not null
#  is_significant   :boolean          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class DifferentialExpressionTest < ActiveRecord::Base
  attr_accessible  :log2_y_over_x, :p_value, :q_value, :sample1, :sample2, 
                   :is_significant?, :test_stat, :test_status_name
  
  #Associations
  #has_one :test_status, :foreign_key => :name
  has_one :gene, :dependent => :destroy
  has_one :transcript, :dependent => :destroy
  
  #Validations
  validates :sample1, :presence => true
  validates :sample2, :presence => true
  validates :test_status_name, :presence => true,
          :inclusion => { :in => %w(OK LOWDATA HIDATA FAIL) }
  validates :fpkm_x, :presence => true,
          :numericality => { :only_double => true }
  validates :fpkm_y, :presence => true,
          :numericality => { :only_double => true }
  validates :log2_y_over_x, :presence => true,
          :numericality => { :only_double => true }
  validates :test_stat, :presence => true,
          :numericality => { :only_double => true }
  validates :p_value, :presence => true,
          :numericality => { :only_double => true }
  validates :q_value, :presence => true,
          :numericality => { :only_double => true }
  validates :is_significant, :presence => true,
          :inclusion => { :in => [true, false] }
end
