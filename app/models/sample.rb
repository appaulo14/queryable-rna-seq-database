# == Schema Information
#
# Table name: samples
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  dataset_id :integer          not null
#

class Sample < ActiveRecord::Base
  attr_accessible :dataset, :name
  
  validates :name, :presence => true
  
  belongs_to :dataset
  has_many :fpkm_samples, :dependent => :destroy
  has_many :sample_comparisons, :as => :sample_1, :dependent => :destroy
  has_many :samples, :through => :sample_comparisons
end
