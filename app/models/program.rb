# == Schema Information
#
# Table name: programs
#
#  name        :string(255)      not null, primary key
#  description :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Program < ActiveRecord::Base
  attr_accessible :name
end
