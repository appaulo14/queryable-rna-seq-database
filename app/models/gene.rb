# == Schema Information
#
# Table name: genes
#
#  id                              :integer          not null, primary key
#  differential_expression_test_id :integer          not null
#  name_from_program               :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class Gene < ActiveRecord::Base
  #attr_accessible :differential_expression_test_id, :job_id, :program_id
  attr_accessible :differential_expression_test, :job, :name_from_program
    
  #Associations
  belongs_to :job
  has_many :transcripts, :dependent => :destroy
  belongs_to :differential_expression_test
  validates_associated :job, :transcripts, :differential_expression_test
  
  #Validation
  #validates :id, :presence => true
  validates :differential_expression_test_id, :presence => true
  validates :job_id, :presence => true
  validates :name_from_program, :presence => true
end
