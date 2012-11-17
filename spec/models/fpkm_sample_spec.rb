# == Schema Information
#
# Table name: fpkm_samples
#
#  sample_number :integer          not null, primary key
#  q_fpkm        :decimal(, )      not null
#  q_fpkm_hi     :decimal(, )      not null
#  q_fpkm_lo     :decimal(, )      not null
#  q_status      :string(255)      not null
#  transcript_id :integer          not null. primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe FpkmSample do
  pending "add some examples to (or delete) #{__FILE__}"
end
