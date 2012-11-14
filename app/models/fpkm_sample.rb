class FpkmSample < ActiveRecord::Base
  attr_accessible :gene_id, :q_FPKM, :q_FPKM_hi, :q_FPKM_lo, :q_status, :sample_number, :transcript_id
end
