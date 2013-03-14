# == Schema Information
#
# Table name: genes
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  name_from_program :string(255)      not null
#


class Gene < ActiveRecord::Base
  #attr_accessible :differential_expression_test_id, :job_id, :program_id
  attr_accessible :dataset, :name_from_program
    
  #Associations
  belongs_to :dataset
  has_many :transcripts#, :dependent => :destroy
  has_many :differential_expression_tests, :dependent => :destroy
  #has_many :fpkm_samples #FIXME: Remove this association since it is not needed because there is no query gene isoforms workflow
  #validates_associated :job, :transcripts, :differential_expression_test
  
  validates :name_from_program, :presence => true
  validates :dataset, :presence => true
  #Validation
  #validates :id, :presence => true
#   validates :differential_expression_test_id, :presence => true
#   validates :job_id, :presence => true
#   validates :name_from_program, :presence => true
end
