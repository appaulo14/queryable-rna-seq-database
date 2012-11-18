# == Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  current_job_status     :string(255)
#  current_program_status :string(255)
#  eid_of_owner           :string(255)
#  workflow_step_id       :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'spec_helper'

describe Job do
  pending "add some examples to (or delete) #{__FILE__}"

  it "should require a unique id"
  
  it "should require the email of the job owner"
  
  it "should destroy all genes associated with it when it is destroyed"
  
  it "should destroy all transcripts associated with it when it is destroyed"
  
  it "should respond to genes"
  
  it "should respond to transcripts"
  
  it "should be invalid if an associated gene is invalid"
  
  it "should be invalid if an associated transcript is invalid"
end
