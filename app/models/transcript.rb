class Transcript < ActiveRecord::Base
  attr_accessible :differential_expression_test_id, :gene_id, :job_id, :program_id, :sequence
end
