class GeneHasGoTerm < ActiveRecord::Base
  attr_accessible :gene, :go_term
  
  belongs_to :gene
  belongs_to :go_term
end
