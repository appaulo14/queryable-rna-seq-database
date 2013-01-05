# == Schema Information
#
# Table name: sample_comparisons
#
#  sample_1_id :integer          not null, primary key
#  sample_2_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class SampleComparison < ActiveRecord::Base
  attr_accessible :sample_1, :sample_2
  belongs_to :sample_1, :class_name => 'Sample'
  belongs_to :sample_2, :class_name => 'Sample'
end
