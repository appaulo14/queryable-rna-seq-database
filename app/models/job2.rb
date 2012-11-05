# == Schema Information
#
# Table name: job2s
#
#  id                           :integer          not null, primary key
#  eid_of_owner                 :string(255)
#  current_program_display_name :string(255)
#  workflow                     :string(255)
#  current_step                 :string(255)
#  next_step                    :string(255)
#  number_of_samples            :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class Job2 < ActiveRecord::Base
  attr_accessible :current_step, :eID_of_owner, :next_step, :workflow
end
