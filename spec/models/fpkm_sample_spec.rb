# == Schema Information
#
# Table name: fpkm_samples
#
#  id            :integer          not null, primary key
#  gene_id       :integer
#  transcript_id :integer
#  sample_name   :string(255)      not null
#  fpkm          :integer          not null
#  fpkm_hi       :integer
#  fpkm_lo       :integer
#  status        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe FpkmSample do
  pending "add some examples to (or delete) #{__FILE__}"
end
