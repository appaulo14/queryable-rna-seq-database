# == Schema Information
#
# Table name: program_statuses
#
#  internal_name :string(255)      not null, primary key
#  display_name  :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Program_Status < ActiveRecord::Base
  attr_accessible :internal_name, :display_name
  
  self.primary_key = :internal_name
  
  has_many :jobs
end
