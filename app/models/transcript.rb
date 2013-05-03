# == Description
#
# Represents a transcript from the upload data files.
#
#
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
  
  ###
  # The GoTerm records associated with this Transcript.
  def go_terms
    return GoTerm.where("id in (?)", self.transcript_has_go_terms.map{|t| t.go_term_id})
  end
end
