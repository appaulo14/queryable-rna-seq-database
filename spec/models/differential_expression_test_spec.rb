# == Schema Information
#
# Table name: differential_expression_tests
#
#  id               :integer          not null, primary key
#  sample1          :string(255)      not null
#  sample2          :string(255)      not null
#  test_status_name :string(255)      not null
#  FPKMx            :decimal(, )      not null
#  FPKMy            :decimal(, )      not null
#  log2_y_over_x    :decimal(, )      not null
#  test_stat        :decimal(, )      not null
#  p_value          :decimal(, )      not null
#  q_value          :decimal(, )      not null
#  significant?     :boolean          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe DifferentialExpressionTest do
  pending "add some examples to (or delete) #{__FILE__}"
end
