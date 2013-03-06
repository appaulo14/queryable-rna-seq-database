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
  validates :dataset, :presence => true
  
  belongs_to :dataset
  has_many :fpkm_samples, :dependent => :destroy
  has_many :comparison_as_sample_1, :class_name => 'SampleComparison', :foreign_key => 'sample_1_id', :dependent => :destroy
  has_many :comparison_as_sample_2, :class_name => 'SampleComparison', :foreign_key => 'sample_2_id', :dependent => :destroy
  #has_many :samples, :through => :sample_comparisons
end
