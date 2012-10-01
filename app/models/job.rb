# == Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  job_status             :string(255)
#  current_program        :string(255)
#  current_program_status :string(255)
#  eID_of_owner           :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Job < ActiveRecord::Base
  attr_accessible :current_program, :current_program_status, :eID_of_owner, :job_status
end
