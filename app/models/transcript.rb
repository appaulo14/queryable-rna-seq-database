# == Schema Information
#
# Table name: transcripts
#
#  id                              :integer          not null, primary key
#  differential_expression_test_id :integer          not null
#  job_id                          :integer          not null
#  gene_id                         :integer          not null
#  sequence                        :text             not null
#  program_id                      :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class Transcript < ActiveRecord::Base
  attr_accessible :differential_expression_test_id, :gene_id, :job_id, :program_id, :sequence
  
  #Associations
  belongs_to :job
  has_one :gene
  has_one :differential_expression_test, :dependent => :destroy
  has_many :fpkm_samples, :dependent_destroy
  
  #Validation
  validates :id, :presence => true
  validates :differential_expression_test_id, :presence => true
  validates :job_id, :presence => true
  validates :gene_id, :presence => true
  validates :sequence, :presence => true
  validates :program_id, :presence => true
end
