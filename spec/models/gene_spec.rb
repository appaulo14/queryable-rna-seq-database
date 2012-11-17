# == Schema Information
#
# Table name: genes
#
#  id                              :integer          not null, primary key
#  differential_expression_test_id :integer          not null
#  name_from_program               :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'spec_helper'

describe Gene do
  it "should create a new instances when given valid attributes"

  it "should require a unique id"
  
  it "should require a name from the program (ex. cufflinks)"
    
  describe "relationship with a differential expression test" do
    it "should require a differential expression test"

    it "should respond to differential_expression_test"

    it "should be invalid if the associated differential_expression_test " +
       "is invalid"
  end
  
  describe "relationship with transcripts" do
    it "should respond to transcripts"
    
    it "should require at least one transcript"

    it "should be invalid if any associated trascripts are invalid"
  end
end
