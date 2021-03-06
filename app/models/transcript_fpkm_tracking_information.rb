# == Description
#
# Represents additional transcript classification information for a Transcript.
#
#
# == Schema Information
#
# Table name: transcript_fpkm_tracking_informations
#
#  transcript_id :integer          not null, primary key
#  class_code    :string(255)      not null
#  length        :integer          not null
#  coverage      :string(255)
#
class TranscriptFpkmTrackingInformation < ActiveRecord::Base
  attr_accessible :class_code, :coverage, :length, :transcript
  
  # The possible valid values for the class_code attribute
  POSSIBLE_CLASS_CODES = %w(= c j e i o p r u x s . -) 
  
  belongs_to :transcript
  
  validates :transcript, :presence => true
  validates :class_code, :presence => true,
                         :inclusion => { :in => POSSIBLE_CLASS_CODES }
  validates :length, :presence => true,
                     :numericality => {
                        :only_integer => true, :greater_than_or_equal_to => 0 
                     }
end
