# == Schema Information
#
# Table name: datasets
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Dataset < ActiveRecord::Base
  attr_accessible :user, :name
  
  belongs_to :user
  has_many :genes
  has_many :transcripts
end
