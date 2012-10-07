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

require 'spec_helper'

describe Job do
  pending "add some examples to (or delete) #{__FILE__}"
end
