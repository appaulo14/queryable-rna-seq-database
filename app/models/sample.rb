# == Description
#
# Sample represents a sample from one of the uploaded data files. 
# For example, one sample might be from the spleen and another from the 
# pancreas of the same organism. 
#
#
# == Schema Information
#
# Table name: samples
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  sample_type :string(255)      not null
#  dataset_id  :integer          not null
#

class Sample < ActiveRecord::Base
  attr_accessible :dataset, :name, :sample_type
  
  # The possible valid values for the sample_type attribute
  AVAILABLE_SAMPLE_TYPES = ['transcript','gene','both']
  
  validates :name, :presence => true
  validates :dataset, :presence => true
  validates :sample_type, :presence => true,
                   :inclusion => {:in => AVAILABLE_SAMPLE_TYPES}
  
  belongs_to :dataset
  has_many :fpkm_samples, :dependent => :destroy
  has_many :comparison_as_sample_1, :class_name => 'SampleComparison', 
                                    :foreign_key => 'sample_1_id', 
                                    :dependent => :destroy
  has_many :comparison_as_sample_2, :class_name => 'SampleComparison', 
                                    :foreign_key => 'sample_2_id', 
                                    :dependent => :destroy
  #has_many :samples, :through => :sample_comparisons
end
