# == Schema Information
#
# Table name: go_terms
#
#  id   :string(255)      not null, primary key
#  term :string(255)      not null
#

# == Description
#
# GoTerm represents a gene ontology (GO) term from the website 
# http://geneontology.org, which provides a structured vocabulary for 
# talking about genes. Since RNA-seq data centers around transcripts, 
# go terms in this database are linked to the transcripts table 
# instead of the genes table.  
#
#
class GoTerm < ActiveRecord::Base
  attr_accessible :term, :id
  
  validates :id, :presence => true, 
                 :format => /\AGO:\d+\z/
  validates :term, :presence => true
  
  has_many :transcript_has_go_terms, :dependent => :destroy
  has_many :transcripts, :through => :transcript_has_go_terms
  
end
