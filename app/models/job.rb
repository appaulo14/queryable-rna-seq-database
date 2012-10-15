# == Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  current_job_status     :string(255)      not null
#  current_program_status :string(255)      not null
#  eid_of_owner           :string(255)      not null
#  workflow_step_id       :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

# == Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  current_job_status     :string(255)      not null
#  current_program_status :string(255)      not null
#  eid_of_owner           :string(255)      not null
#  workflow_step_id       :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Job < ActiveRecord::Base
    attr_accessible :id, :current_job_status, :current_program_status, :eid_of_owner, :workflow_step_id
    has_one :job_status, :foreign_key => "current_job_status"
    has_one :program_status, :foreign_key => "current_program_status"
    belongs_to :users, :foreign_key => "eid_of_owner"
    has_one :workflow_step, :foreign_key => "workflow_step_id"
end
