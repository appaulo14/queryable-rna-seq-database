# == Schema Information
#
# Table name: fpkm_samples
#
#  id            :integer          not null, primary key
#  gene_id       :integer
#  transcript_id :integer
#  sample_id     :integer          not null
#  fpkm          :decimal(, )      not null
#  fpkm_hi       :decimal(, )
#  fpkm_lo       :decimal(, )
#  status        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# == Schema Information
#
# Table name: fpkm_samples
#
#  id            :integer          not null, primary key
#  gene_id       :integer
#  transcript_id :integer
#  sample_name   :string(255)      not null
#  fpkm          :decimal(, )      not null
#  fpkm_hi       :decimal(, )
#  fpkm_lo       :decimal(, )
#  status        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe FpkmSample do
  pending "add some examples to (or delete) #{__FILE__}"
  
  it 'should test for numbers being too big'
end
