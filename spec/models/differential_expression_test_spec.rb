# == Schema Information
#
# Table name: differential_expression_tests
#
#  id               :integer          not null, primary key
#  fpkm_sample_1_id :integer
#  fpkm_sample_2_id :integer
#  test_status      :string(255)
#  log2_fold_change :integer
#  p_value          :integer
#  q_value          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe DifferentialExpressionTest do
  pending "add some examples to (or delete) #{__FILE__}"
end
