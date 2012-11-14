class Gene < ActiveRecord::Base
  attr_accessible :differential_expression_test_id, :job_id, :program_id
end
