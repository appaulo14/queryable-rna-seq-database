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

class GoTerm < ActiveRecord::Base
  establish_connection :b2gdb

  self.table_name = 'term'
  
  #attr_accessible :id, :term
  
  validates :id, :presence => true, 
                 :format => /\AGO:\d+\z/
  validates :term, :presence => true
  
  has_many :transcript_has_go_terms, :dependent => :destroy
  has_many :transcripts, :through => :transcript_has_go_terms
  
  #Overide these methods because they shouldn't do anything
  def destroy()
    raise NotImplementedError, "GO Terms are in a different db and should " +
                                  "not be manipulated from here"
  end
  def delete()
    raise NotImplementedError, "GO Terms are in a different db and should " +
                                  "not be manipulated from here"
  end
  def delete()
    raise NotImplementedError, "GO Terms are in a different db and should " +
                                  "not be manipulated from here"
  end
end
