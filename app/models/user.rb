# == Schema Information
#
# Table name: users
#
#  eid        :string(255)      not null, primary key
#  email      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :eid, :email
  self.primary_key = :eid
  has_many :jobs
  
  validates :eid, :presence => true
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :presence   => true,
                    :format     => { :with => email_regex }
end
