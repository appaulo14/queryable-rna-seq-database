# == Schema Information
#
# Table name: differential_expression_tests
#
#  id               :integer          not null, primary key
#  fpkm_sample_1_id :integer
#  fpkm_sample_2_id :integer
#  gene_id          :integer
#  transcript_id    :integer
#  test_status      :string(255)
#  log2_fold_change :decimal(, )
#  p_value          :decimal(, )
#  q_value          :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe DifferentialExpressionTest do
  pending "add some examples to (or delete) #{__FILE__}"
end
