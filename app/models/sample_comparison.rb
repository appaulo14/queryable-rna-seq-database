# == Schema Information
#
# Table name: sample_comparisons
#
#  id          :integer          not null, primary key
#  sample_1_id :integer          not null
#  sample_2_id :integer          not null
#

class SampleComparison < ActiveRecord::Base
  attr_accessible :sample_1, :sample_2
  belongs_to :sample_1, :class_name => 'Sample'
  belongs_to :sample_2, :class_name => 'Sample'
  has_many :differential_expression_tests
end
