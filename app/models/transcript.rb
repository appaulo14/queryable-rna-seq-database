# == Schema Information
#
# Table name: transcripts
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  gene_id           :integer
#  name_from_program :string(255)      not null
#

# == Schema Information
#
# Table name: transcripts
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  gene_id           :integer
#  name_from_program :string(255)      not null
#  blast_seq_id      :string(255)      not null
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
  has_many :differential_expression_tests#, :dependent => :destroy
  has_many :fpkm_samples#, :dependent => :destroy
  has_many :transcript_has_go_terms
  has_many :go_terms, :through => :transcript_has_go_terms
  #validates_associated :job, :gene, :differential_expression_test, :fpkm_samples
  
  #Validation
#   validates :id, :uniqueness => true
#   validates :differential_expression_test_id, :presence => true
#   validates :job_id, :presence => true
#   #validates :gene_id, :presence => true
#   validates :fasta_sequence, :presence => true,
#                        :format => { :with => NUCLEOTIDE_FASTA_SEQUENCE_REGEX }   
#   validates :name_from_program, :presence => true
#   validate  :transcript_and_gene_have_same_job
  
  private
  def transcript_and_gene_have_same_job
    if gene.nil? == false and job_id != gene.job_id
      errors[:job] << "Job must be the same for the both the " +
                       "transcript its associated gene"
    end
  end
end
