# == Schema Information
#
# Table name: fpkm_samples
#
#  sample_number :integer          not null, primary key
#  q_fpkm        :decimal(, )      not null
#  q_fpkm_hi     :decimal(, )      not null
#  q_fpkm_lo     :decimal(, )      not null
#  q_status      :string(255)      not null
#  transcript_id :integer          not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class FpkmSample < ActiveRecord::Base
  attr_accessible :gene_id, :q_fpkm, :q_fpkm_hi, :q_fpkm_lo, :q_status, :sample_number, :transcript_id
  
  #Associations
  belongs_to :transcript
  
  #Validation
  validates :sample_number, :presence => true,
          :numericality => { :only_integer => true, :greater_than => 0 }
  validates :q_fpkm, :presence => true,
          :numericality => { :only_double => true }
  validates :q_fpkm_hi, :presence => true,
          :numericality => { :only_double => true }
  validates :q_fpkm_lo, :presence => true,
          :numericality => { :only_double => true }
  validates :q_status, :presence => true,
          :inclusion => { :in => %w(OK LOWDATA HIDATA FAIL) }
  validates :transcript, :presence => true
end
