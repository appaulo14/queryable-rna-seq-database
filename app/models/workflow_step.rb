class WorkflowStep < ActiveRecord::Base
  attr_accessible :programs_internal_name, :step, :workflows_id
end
