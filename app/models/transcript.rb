# == Schema Information
#
# Table name: transcripts
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  gene_id           :integer
#  name_from_program :string(255)      not null
#

class Transcript < ActiveRecord::Base
    attr_accessible :gene, :dataset, :name_from_program
  
  ###Constants###
  #Based off the NCBI fasta format guide: 
  #     http://www.ncbi.nlm.nih.gov/blast/blastcgihelp.shtml
  NUCLEOTIDE_FASTA_SEQUENCE_REGEX = /\A[ACGTNUKSYMWRBDHV\-]+\z/i 
  
  #Associations
  belongs_to :dataset
  belongs_to :gene
  has_one :transcript_fpkm_tracking_information, :dependent => :destroy
  has_many :differential_expression_tests, :dependent => :destroy
  has_many :fpkm_samples, :dependent => :destroy
  has_many :transcript_has_go_terms, :dependent => :destroy
#  has_many :go_terms, :through => :transcript_has_go_terms
  
  #Validation
  validates :dataset, :presence => true
  validates :name_from_program, :presence => true
  
  def go_terms
    return GoTerm.where("id in (?)", self.transcript_has_go_terms.map{|t| t.go_term_id})
  end
end
