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

require 'spec_helper'

describe Sample do
  pending "add some examples to (or delete) #{__FILE__}"
end
