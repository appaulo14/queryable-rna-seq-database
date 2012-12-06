class GeneHasGoTerm < ActiveRecord::Base
  attr_accessible :gene_id, :go_term_id
  
  belongs_to :gene
  belongs_to :go_term
end
