# == Schema Information
#
# Table name: fpkm_samples
#
#  id            :integer          not null, primary key
#  transcript_id :integer          not null
#  sample_id     :integer          not null
#  fpkm          :float            not null
#  fpkm_hi       :float
#  fpkm_lo       :float
#  status        :string(255)
#

require 'spec_helper'

describe FpkmSample do
  before(:each) do 
    @it = FactoryGirl.build(:fpkm_sample)
  end
  
  it 'should be able to preserve large numbers' do
    @it.fpkm = 1e100.to_s
    @it.save
    @it.reload
    @it.fpkm.to_f.should eq(1e100)
  end
end
