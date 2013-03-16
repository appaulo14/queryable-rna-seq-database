# == Schema Information
#
# Table name: transcripts
#
#  id                :integer          not null, primary key
#  dataset_id        :integer          not null
#  gene_id           :integer
#  name_from_program :string(255)      not null
#


require 'spec_helper'

describe Transcript do
  before(:each) do
    @it = FactoryGirl.build(:transcript)
  end

end
