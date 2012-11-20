# == Schema Information
#
# Table name: programs
#
#  internal_name :string(255)      default(""), not null, primary key
#  display_name  :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Program < ActiveRecord::Base
    attr_accessible :display_name, :internal_name
    
    self.primary_key = :internal_name
    
    has_many :workflow_steps
end
