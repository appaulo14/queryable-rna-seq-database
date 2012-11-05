# == Schema Information
#
# Table name: samples
#
#  id         :integer          not null, primary key
#  sample_id  :integer
#  job_id     :integer
#  status     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Sample < ActiveRecord::Base
  attr_accessible :job_id, :sample_id, :status
end
