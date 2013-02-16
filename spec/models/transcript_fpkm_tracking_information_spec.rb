# == Schema Information
#
# Table name: transcript_fpkm_tracking_informations
#
#  transcript_id :integer          not null, primary key
#  class_code    :string(255)
#  length        :integer
#  coverage      :decimal(, )
#

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

require 'spec_helper'

describe TranscriptFpkmTrackingInformation do
  pending "add some examples to (or delete) #{__FILE__}"
end
