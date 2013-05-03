# == Description
#
# Represents a gene from the upload data files.
#
#
# == Schema Information
#
# Table name: genes
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  name_from_program :string(255)      not null
#


class Gene < ActiveRecord::Base
  attr_accessible :dataset, :name_from_program
    
  #Associations
  belongs_to :dataset
  has_many :transcripts
  has_many :differential_expression_tests, :dependent => :destroy
  
  validates :name_from_program, :presence => true
  validates :dataset, :presence => true
end
