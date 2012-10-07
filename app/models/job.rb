# == Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  job_status             :string(255)      not null
#  current_program_status :string(255)      not null
#  eid_of_owner           :string(255)      not null
#  workflow_step_id       :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Job < ActiveRecord::Base
    attr_accessible :id, :job_status, :current_program_status, :eid_of_owner, :workflow_step_id
    has_one :job_status
    has_one :program_status
    belongs_to :users
    has_one :workflow_step
end
