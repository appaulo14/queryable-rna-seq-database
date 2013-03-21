require 'spec_helper'

shared_examples_for 'a required attribute' do
  it 'should not be valid for nil' do
    @it.send("#{@attribute}=",nil)
    @it.should_not be_valid
  end
  
  it 'should not be valid for an empty string' do
    @it.send("#{@attribute}=",'')
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

shared_examples_for 'a view model-style boolean' do
  it 'should be valid for "1"' do
    @it.send("#{@attribute}=",'1')
    @it.should be_valid
  end
  it 'should be valid for "0"' do
    @it.send("#{@attribute}=",'0')
    @it.should be_valid
  end
  
  it 'should not be valid for strings besides "0" or "1"' do
    ["", "hello", "llamas"].each do |invalid_string|
      @it.send("#{@attribute}=",invalid_string)
      @it.should_not be_valid
    end
  end
  
  it 'should not be valid for integer value 1' do
    @it.send("#{@attribute}=",1)
    @it.should_not be_valid
  end
  
  it 'should not be valid for integer value 0' do
    @it.send("#{@attribute}=",0)
    @it.should_not be_valid
  end
  
  it 'should not be valid for double value 1.0' do
    @it.send("#{@attribute}=",1.0)
    @it.should_not be_valid
  end
  
  it 'should not be valid for double value 0.0' do
    @it.send("#{@attribute}=",0.0)
    @it.should_not be_valid
  end
  
  it 'should not be valid for boolean true' do
    @it.send("#{@attribute}=",true)
    @it.should_not be_valid
  end
  
  it 'should not be valid for boolean false' do
    @it.send("#{@attribute}=",false)
    @it.should_not be_valid
  end
end
