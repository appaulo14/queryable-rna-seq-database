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

class Workflow_Step < ActiveRecord::Base
  attr_accessible :program_internal_name, :step, :workflow_id
  
  has_one :program
  has_one :workflow
  has_many :jobs
end
