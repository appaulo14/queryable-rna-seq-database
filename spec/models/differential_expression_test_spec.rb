# == Schema Information
#
# Table name: differential_expression_tests
#
#  id                   :integer          not null, primary key
#  gene_id              :integer
#  transcript_id        :integer
#  sample_comparison_id :integer          not null
#  test_status          :string(255)      not null
#  sample_1_fpkm        :float            not null
#  sample_2_fpkm        :float            not null
#  log_fold_change      :float            not null
#  test_statistic       :float            not null
#  p_value              :float            not null
#  fdr                  :float            not null
#

require 'spec_helper'

describe DifferentialExpressionTest do
  pending "add some examples to (or delete) #{__FILE__}"
end
