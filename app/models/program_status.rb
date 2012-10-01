# == Schema Information
#
# Table name: program_statuses
#
#  name        :string(255)      not null, primary key
#  description :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProgramStatus < ActiveRecord::Base
  attr_accessible :name
end
