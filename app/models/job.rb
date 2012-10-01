class Job < ActiveRecord::Base
  attr_accessible :current_program, :current_program_status, :eID_of_owner, :job_status
end
