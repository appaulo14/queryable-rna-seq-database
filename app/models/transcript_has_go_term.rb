# == Schema Information
#
# Table name: transcript_has_go_terms
#
#  transcript_id :integer
#  go_term_id    :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TranscriptHasGoTerm < ActiveRecord::Base
  attr_accessible :transcript, :go_term
  
  belongs_to :transcript
  belongs_to :go_term
end
