# == Schema Information
#
# Table name: transcript_fpkm_tracking_informations
#
#  transcript_id :integer          not null, primary key
#  class_code    :string(255)
#  length        :integer
#  coverage      :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TranscriptFpkmTrackingInformation < ActiveRecord::Base
  attr_accessible :class_code, :coverage, :length, :transcript
  
  POSSIBLE_CLASS_CODES = %w(= c j e u o p r u x s . -)
  
  belongs_to :transcript
end
