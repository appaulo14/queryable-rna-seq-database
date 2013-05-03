# == Description
#
# Represents an FPKM sample for a given transcript and sample. FPKM is a 
# way to measure gene and transcript expression. Since each sample has 
# different expression levels, each sample has different FPKM values for each 
# of its genes and transcripts. Although a gene has an FpkmSample, unlike 
# transcripts, there is no use case to directly query a gene’s fpkm samples. 
# A gene’s FpkmSamples are only accessed through the gene’s differential 
# expression tests page. Therefore, no direct link between the two is required. 
#
#
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
  
  # The available valid values for the status
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
