# == Schema Information
#
# Table name: fpkm_samples
#
#  id            :integer          not null, primary key
#  transcript_id :integer          not null
#  sample_id     :integer          not null
#  fpkm          :string(255)      not null
#  fpkm_hi       :string(255)      not null
#  fpkm_lo       :string(255)      not null
#  status        :string(255)      not null
#


class FpkmSample < ActiveRecord::Base
  attr_accessible :transcript, :fpkm, :fpkm_hi, :fpkm_lo, :status, 
                  :sample
  POSSIBLE_STATUSES = ['OK','LOWDATA','HIDATA','FAIL']
  
  #Associations
  belongs_to :transcript
  belongs_to :sample
  
  #Validation
  validates :transcript, :presence => true
  validates :sample, :presence => true
  
  validates :fpkm, :presence => true,
                   :numericality => true
  validates :fpkm_lo, :allow_nil => true,
                      :numericality => true
  validates :fpkm_hi, :allow_nil => true,
                      :numericality => true

  validates :status,:presence => true,
                    :inclusion => { :in => POSSIBLE_STATUSES }

end
