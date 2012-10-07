# == Schema Information
#
# Table name: workflow_steps
#
#  id                    :integer          not null, primary key
#  workflow_id           :integer
#  program_internal_name :string(255)
#  step                  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe WorkflowStep do
  pending "add some examples to (or delete) #{__FILE__}"
end
