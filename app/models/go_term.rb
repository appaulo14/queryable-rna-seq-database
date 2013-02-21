# == Schema Information
#
# Table name: go_terms
#
#  id   :string(255)      not null, primary key
#  term :string(255)      not null
#

# == Schema Information
#
# Table name: go_terms
#
#  id   :string(255)      not null, primary key
#  term :string(255)      not null
#

class GoTerm < ActiveRecord::Base
  attr_accessible :id, :term
  
  has_many :transcript_has_go_terms
  has_many :transcripts, :through => :transcript_has_go_terms
end
