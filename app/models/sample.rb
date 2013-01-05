# == Schema Information
#
# Table name: samples
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  dataset_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Sample < ActiveRecord::Base
  attr_accessible :dataset, :name
  
  belongs_to :dataset
  has_many :fpkm_samples
  has_many :sample_comparisons
  has_many :samples, :through => :sample_comparisons
end
