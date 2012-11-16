# == Schema Information
#
# Table name: test_statuses
#
#  name        :string(255)      not null, primary key
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class TestStatus < ActiveRecord::Base
  attr_accessible :description, :name
  
  #Associations
  #has_many :differential_expression_tests
  
  #Validations
  validates :name, :presence => true
end
