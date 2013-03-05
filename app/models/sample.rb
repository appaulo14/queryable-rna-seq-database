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
  has_many :sample_comparison_1s, :class_name => 'SampleComparison', :foreign_key => 'sample_1_id', :dependent => :destroy
  has_many :sample_comparison_2s, :class_name => 'SampleComparison', :foreign_key => 'sample_2_id', :dependent => :destroy
  #has_many :samples, :through => :sample_comparisons
end
