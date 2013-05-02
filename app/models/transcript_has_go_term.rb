# == Schema Information
#
# Table name: transcript_has_go_terms
#
#  transcript_id :integer          not null
#  go_term_id    :integer          not null
#

class TranscriptHasGoTerm < ActiveRecord::Base
  attr_accessible :transcript, :go_term
  self.primary_keys = :transcript_id, :go_term_id
      
  validates :transcript, :presence => true
  validates :go_term, :presence => true
  
  belongs_to :transcript
  belongs_to :go_term
end
