# == Schema Information
#
# Table name: genes
#
#  id                              :integer          not null, primary key
#  differential_expression_test_id :integer          not null
#  job_id                          :integer          not null
#  program_id                      :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'spec_helper'

describe Gene do
  pending "add some examples to (or delete) #{__FILE__}"
end
