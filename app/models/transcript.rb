# == Schema Information
#
# Table name: transcripts
#
#  id                              :integer          not null, primary key
#  differential_expression_test_id :integer          not null
#  job_id                          :integer          not null
#  gene_id                         :integer          not null
#  sequence                        :text             not null
#  name_from_program               :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class Transcript < ActiveRecord::Base
  #attr_accessible :differential_expression_test_id, :gene_id, :job_id, :program_id, :sequence
    attr_accessible :differential_expression_test, :gene, :job, :program, :sequence, :name_from_program
  
  ###Constants###
  #Based off the NCBI fasta format guide: 
  #     http://www.ncbi.nlm.nih.gov/blast/blastcgihelp.shtml
  NUCLEOTIDE_FASTA_SEQUENCE_REGEX = /\A[ACGTNUKSYMWRBDHV\-]+\z/i 
  
  #Associations
  belongs_to :job
  belongs_to :gene
  belongs_to :differential_expression_test
  has_many :fpkm_samples, :dependent => :destroy
  validates_associated :job, :gene, :differential_expression_test, :fpkm_samples
  
  #Validation
  #validates :id, :presence => true
  validates :differential_expression_test_id, :presence => true
  validates :job_id, :presence => true
  validates :gene_id, :presence => true
  validates :sequence, :presence => true,
                       :format => { :with => NUCLEOTIDE_FASTA_SEQUENCE_REGEX }   
  validates :name_from_program, :presence => true
end
