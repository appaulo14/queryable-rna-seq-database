# == Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  job_status             :string(255)      not null
#  current_program_status :string(255)      not null
#  eid_of_owner           :string(255)      not null
#  workflow_steps_id      :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Job < ActiveRecord::Base
    has_one :job_status
    has_one :program_status
    belongs_to :users
    has_one :workflow_step
end
