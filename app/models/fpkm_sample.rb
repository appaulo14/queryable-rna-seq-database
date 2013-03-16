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


class FpkmSample < ActiveRecord::Base
  attr_accessible :transcript, :fpkm, :fpkm_hi, :fpkm_lo, :status, 
                  :sample
  POSSIBLE_STATUSES = ['NOTEST','LOWDATA','HIDATA','FAIL']
  
  #Associations
  belongs_to :transcript
  belongs_to :sample
  
  #Validation
#   validates :sample_number, :presence => true,
#           :numericality => { :only_integer => true, :greater_than => 0 }
   validates :fpkm, :presence => true,
           :numericality => { :only_float => true }
#   validates :q_fpkm_hi, :presence => true,
#           :numericality => { :only_double => true }
#   validates :q_fpkm_lo, :presence => true,
#           :numericality => { :only_double => true }
#   validates :q_status, :presence => true,
#           :inclusion => { :in => %w(OK LOWDATA HIDATA FAIL) }
#   validates :transcript, :presence => true
end
