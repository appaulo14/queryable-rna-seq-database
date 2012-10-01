# == Schema Information
#
# Table name: job_statuses
#
#  name        :string(255)      not null, primary key
#  description :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class JobStatus < ActiveRecord::Base
  attr_accessible :description, :name
end
