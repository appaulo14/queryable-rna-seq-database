class TranscriptHasGoTerm < ActiveRecord::Base
  attr_accessible :transcript, :go_term
  
  belongs_to :transcript
  belongs_to :go_term
end
