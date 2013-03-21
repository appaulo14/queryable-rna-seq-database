# == Schema Information
#
# Table name: fpkm_samples
#
#  id            :integer          not null, primary key
#  transcript_id :integer          not null
#  sample_id     :integer
#  fpkm          :string(255)      not null
#  fpkm_hi       :string(255)
#  fpkm_lo       :string(255)
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
  validate  :fpkm_is_greater_than_or_equal_to_zero
  
  validate  :fpkm_lo_is_greater_than_or_equal_to_zero
  
  validate  :fpkm_hi_is_greater_than_or_equal_to_zero

  validates :status,:presence => true,
                    :inclusion => { :in => POSSIBLE_STATUSES }

  private
  
  def fpkm_is_greater_than_or_equal_to_zero
    is_greater_than_or_equal_to_zero('fpkm')
  end
  
  def fpkm_lo_is_greater_than_or_equal_to_zero
    is_greater_than_or_equal_to_zero('fpkm_lo')
  end
  
  def fpkm_hi_is_greater_than_or_equal_to_zero
    is_greater_than_or_equal_to_zero('fpkm_hi')
  end
  
  def is_greater_than_or_equal_to_zero(attribute)
    return if self.send(attribute).nil?
    begin
      if self.send(attribute).to_f < 0.0
        errors[attribute] << 'must be greater than or equal to zero'
      end
    rescue NoMethodError => ex
      errors[attribute] << 'must be float or double'
    end
  end
end
