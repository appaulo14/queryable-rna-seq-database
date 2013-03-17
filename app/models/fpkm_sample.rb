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
  POSSIBLE_STATUSES = ['OK','LOWDATA','HIDATA','FAIL']
  
  #Associations
  belongs_to :transcript
  belongs_to :sample
  
  #Validation
  validates :transcript, :presence => true
  validates :sample, :presence => true
  
  validates :fpkm, :presence => true
  validate  :fpkm_is_convertable_to_float
  validate  :fpkm_is_greater_than_zero
  
  validate  :fpkm_lo_is_convertable_to_float
  validate  :fpkm_lo_is_greater_than_zero
  
  validate  :fpkm_hi_is_convertable_to_float
  validate  :fpkm_hi_is_greater_than_zero

  validates :status,:allow_nil => true, 
                    :inclusion => { :in => POSSIBLE_STATUSES }
#   validates :transcript, :presence => true

  private
  
  def fpkm_is_convertable_to_float
    begin
      self.fpkm.to_f
    rescue NoMethodError => ex
      errors[:fpkm] << 'fpkm must be float or double'
    end
  end
  
  def fpkm_is_greater_than_zero
    if self.fpkm.to_f <= 0.0
      errors[:fpkm] << 'fpkm must be greater than zero'
    end
  end
  
  def fpkm_lo_is_convertable_to_float
    begin
      self.fpkm_lo.to_f
    rescue NoMethodError => ex
      errors[:fpkm_lo] << 'fpkm must be float or double'
    end
  end
  
  def fpkm_lo_is_greater_than_zero
    return if self.fpkm_lo.nil?
    if self.fpkm_lo.to_f <= 0.0
      errors[:fpkm_lo] << 'fpkm must be greater than zero'
    end
  end
  
  def fpkm_hi_is_convertable_to_float
    begin
      self.fpkm_hi.to_f
    rescue NoMethodError => ex
      errors[:fpkm_hi] << 'fpkm must be float or double'
    end
  end
  
  def fpkm_hi_is_greater_than_zero
    return if self.fpkm_hi.nil?
    if self.fpkm_hi.to_f <= 0.0
      errors[:fpkm_hi] << 'fpkm must be greater than zero'
    end
  end
end
