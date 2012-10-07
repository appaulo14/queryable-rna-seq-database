# == Schema Information
#
# Table name: workflows
#
#  id           :integer          not null, primary key
#  display_name :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Workflow < ActiveRecord::Base
  attr_accessible :display_name
  has_many :workflow_steps
end
