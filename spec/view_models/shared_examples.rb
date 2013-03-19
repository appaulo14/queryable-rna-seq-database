require 'spec_helper'

shared_examples_for 'a required attribute' do
  it 'should be required' do
    @it.send("#{@attribute}=",nil)
    @it.should_not be_valid
  end  
end

shared_examples_for 'an uploaded file' do
  it 'should be valid when the type is "ActionDispatch::Http::UploadedFile"' do
    #The factory should make this attribute an uploaded file by default
    @it.send(@attribute).class.to_s.should eq('ActionDispatch::Http::UploadedFile')
    @it.should be_valid
  end
  
  it 'should not be valid when the type is a string' do
    @it.send("#{@attribute}=","")
    @it.should_not be_valid
  end
  
  it 'should not be valid when the type is a hash' do
    @it.send("#{@attribute}=",{})
    @it.should_not be_valid
  end
  
  it 'should not be valid when the type is an object' do
    @it.send("#{@attribute}=",Object.new)
    @it.should_not be_valid
  end
  
  it 'should not be valid when the type is an integer' do
    @it.send("#{@attribute}=",45)
    @it.should_not be_valid
  end
end
