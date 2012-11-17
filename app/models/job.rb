# == Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  current_job_status     :string(255)
#  current_program_status :string(255)
#  eid_of_owner           :string(255)
#  workflow_step_id       :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
#
class Job < ActiveRecord::Base
    attr_accessible :id, :current_job_status, :current_program_status, :eid_of_owner, :workflow_step_id
#     has_one :job_status, :foreign_key => "current_job_status"
#     has_one :program_status, :foreign_key => "current_program_status"
#     belongs_to :users, :foreign_key => "eid_of_owner"
#     has_one :workflow_step, :foreign_key => "workflow_step_id"
    
    #Associations
    has_many :genes, :dependent => :destroy
    has_many :transcripts, :dependent => :destroy
    validates_associated :genes, :transcripts
    
    #Validations
    validates :id, :uniqueness => true
#     validates :current_job_status, :presence => true
#     validates :current_program_status, :presence => true
    validates :eid_of_owner, :presence => true
#     validates :workflow_step_id, :presence => true
end
