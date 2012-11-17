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

require 'spec_helper'

describe Job do
  pending "add some examples to (or delete) #{__FILE__}"
  
  it "should delete all the records dependent upon it"
end
