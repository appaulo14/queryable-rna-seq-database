 #== Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  job_status             :string(255)      not null
#  current_program        :string(255)      not null
#  current_program_status :string(255)      not null
#  eid_of_owner           :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Job < ActiveRecord::Base
  # attr_accessible :title, :body
    belongs_to :job_status
end
