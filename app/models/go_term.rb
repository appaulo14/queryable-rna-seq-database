class GoTerm < ActiveRecord::Base
  attr_accessible :id, :term
  
  has_many :gene_has_go_terms
  has_many :genes, :through => :gene_has_go_terms
end
