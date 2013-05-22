# == Description
#
# GoTerm represents a gene ontology (GO) term from the website 
# http://geneontology.org, which provides a structured vocabulary for 
# talking about genes. Since RNA-seq data centers around transcripts, 
# go terms in this database are linked to the transcripts table 
# instead of the genes table.  
#
#
# == Schema Information
#
# Table name: term
#
#  id          :integer          not null, primary key
#  name        :string(255)      default(""), not null
#  term_type   :string(55)       not null
#  acc         :string(255)      not null
#  is_obsolete :integer          default(0), not null
#  is_root     :integer          default(0), not null
#  is_relation :integer          default(0), not null
#

class B2gdbGoTerm < ActiveRecord::Base
  establish_connection :b2gdb

  self.table_name = 'term'
  
  def readonly?
    return true
  end
  
  ###
  # Overides this method to prevent it from destroying GoTerm records
  # because GoTerm records reside in the blast2go database 
  # and should never be destroyed/deleted from here.
  def destroy()
    raise NotImplementedError, "GO Terms are in a different db and should " +
                                  "not be manipulated from here"
  end
  
  ###
  # Overides this method to prevent it from destroying GoTerm records
  # because GoTerm records reside in the blast2go database 
  # and should never be destroyed/deleted from here.
  def delete()
    raise NotImplementedError, "GO Terms are in a different db and should " +
                                  "not be manipulated from here"
  end
end
