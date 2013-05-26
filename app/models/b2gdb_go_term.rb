# == Description
#
# Represents a GO term record from the MySQL blast2go database, which is 
# separate from the database used in the rest of this Ruby on Rails 
# application. As GO terms are found for transcripts, GO terms are copied from 
# this table into the GoTerm table, which resides in the same database as the 
# rest of the tables for this Ruby on Rails application. 
# GoTerm represents a gene ontology (GO) term from the website 
# http://geneontology.org, which provides a structured vocabulary for 
# talking about genes. 
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
  
  ###
  # Marks that this table can only be read from
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
