# == Schema Information
#
# Table name: term
#
#  id          :integer          not null, primary key
#  name        :string(255)      default(""), not null
#  term_type   :string(55)       not null
#  acc         :string(255)      not null
#  is_obsolete :integer          default(0), not null
#  is_root     :integer          default(0), not null
#  is_relation :integer          default(0), not null
#

require 'spec_helper'
require 'models/shared_examples.rb'

describe B2gdbGoTerm do
  before (:each) do
    @it = B2gdbGoTerm.first()
  end

  it 'should be read-only' do
    @it.readonly?.should be_true
  end
  
  it 'should raise an exception when trying to destroy' do
    lambda do
      @it.destroy()
    end.should raise_error NotImplementedError
  end
  
  it 'should raise an exception when trying to delete' do
    lambda do
      @it.delete()
    end.should raise_error NotImplementedError
  end
end
