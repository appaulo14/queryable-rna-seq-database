# == Schema Information
#
# Table name: fpkm_samples
#
#  sample_number :integer          not null, primary key
#  q_FPKM        :decimal(, )      not null
#  q_FPKM_hi     :decimal(, )      not null
#  q_FPKM_lo     :decimal(, )      not null
#  q_status      :string(255)      not null
#  transcript_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe FpkmSample do
  pending "add some examples to (or delete) #{__FILE__}"
end
