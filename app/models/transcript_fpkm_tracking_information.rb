# == Schema Information
#
# Table name: transcript_fpkm_tracking_informations
#
#  transcript_id :integer          not null, primary key
#  class_code    :string(255)      not null
#  length        :integer          not null
#  coverage      :string(255)
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
  
  POSSIBLE_CLASS_CODES = %w(= c j e i o p r u x s . -) 
  
  belongs_to :transcript
  
  validates :transcript, :presence => true
  validates :class_code, :presence => true,
                         :inclusion => { :in => POSSIBLE_CLASS_CODES }
  validates :length, :presence => true,
                     :numericality => {
                        :only_integer => true, :greater_than_or_equal => 0 
                     }
end
