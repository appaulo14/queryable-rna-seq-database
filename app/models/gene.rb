# == Schema Information
#
# Table name: genes
#
#  id                              :integer          not null, primary key
#  differential_expression_test_id :integer          not null
#  job_id                          :integer          not null
#  program_id                      :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class Gene < ActiveRecord::Base
  attr_accessible :differential_expression_test_id, :job_id, :program_id
  
  #Associations
  belongs_to :jobs
  has_many :transcripts, :dependent => :destroy
  has_one :differential_expression_test, :dependent => :destroy
  
  #Validation
  validates :id, :presence => true
  validates :differential_expression_test_id, :presence => true
  validates :job_id, :presence => true
  validates :program_id, :presence => true
end
