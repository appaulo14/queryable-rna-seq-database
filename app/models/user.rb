# == Schema Information
#
# Table name: users
#
#  eID        :string(45)       not null, primary key
#  email      :string(45)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :eID, :email
  self.primary_key = :eID
  
  validates :eID, :presence => true
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :presence   => true,
                    :format     => { :with => email_regex }
end
