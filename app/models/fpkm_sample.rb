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

class FpkmSample < ActiveRecord::Base
  attr_accessible :gene_id, :q_FPKM, :q_FPKM_hi, :q_FPKM_lo, :q_status, :sample_number, :transcript_id
  
  #Associations
  has_one :transcript
  
  #Validation
  validates :sample_number, :presence => true
  validates :q_FPKM, :presence => true
  validates :q_FPKM_hi, :presence => true
  validates :q_FPKM_lo, :presence => true
  validates :q_status, :presence => true
  validates :transcript_id, :presence => true
end
