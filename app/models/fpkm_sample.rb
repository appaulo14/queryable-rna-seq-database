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
#

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
#

class FpkmSample < ActiveRecord::Base
  attr_accessible :gene, :transcript, :fpkm, :fpkm_hi, :fpkm_lo, :status, 
                  :sample
  POSSIBLE_STATUSES = ['NOTEST','LOWDATA','HIDATA','FAIL']
  
  #Associations
  belongs_to :transcript
  belongs_to :gene
  belongs_to :sample
  
  #Validation
#   validates :sample_number, :presence => true,
#           :numericality => { :only_integer => true, :greater_than => 0 }
#   validates :q_fpkm, :presence => true,
#           :numericality => { :only_double => true }
#   validates :q_fpkm_hi, :presence => true,
#           :numericality => { :only_double => true }
#   validates :q_fpkm_lo, :presence => true,
#           :numericality => { :only_double => true }
#   validates :q_status, :presence => true,
#           :inclusion => { :in => %w(OK LOWDATA HIDATA FAIL) }
#   validates :transcript, :presence => true
end
