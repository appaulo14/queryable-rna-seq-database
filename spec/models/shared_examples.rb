require 'spec_helper'

shared_examples_for 'an ActiveRecord-customized boolean' do
  it "should convert an assignment of 1 to true" do
    @it.send("#{@attribute}=", false)
    @it.send("#{@attribute}=", 1)
    @it.send("#{@attribute}").should be_true
  end
  
  it "should convert an assignment of '1' to true" do
    @it.send("#{@attribute}=", false)
    @it.send("#{@attribute}=", '1')
    @it.send("#{@attribute}").should be_true
  end
  
  it "should convert an assignment of 'true' to true" do
    @it.send("#{@attribute}=", false)
    @it.send("#{@attribute}=", 'true')
    @it.send("#{@attribute}").should be_true
  end
  
  it "should convert string assignments " +
     "besides '1', 'true', and '' to false" do
    ["cat", "helloooo", "tru"].each do |string|
      @it.send("#{@attribute}=",true)
      @it.send("#{@attribute}=",string)
      @it.send("#{@attribute}").should be_false
    end
  end
  
  it 'should convert an empty array assignment to false' do
    @it.send("#{@attribute}=",true)
    @it.send("#{@attribute}=",[])
    @it.send("#{@attribute}").should be_false
  end
  
  it 'should convert an empty hash assignment to false' do
    @it.send("#{@attribute}=",true)
    @it.send("#{@attribute}=",{})
    @it.send("#{@attribute}").should be_false
  end
  
  it 'should convert an object assignment to false' do
    @it.send("#{@attribute}=",true)
    @it.send("#{@attribute}=",Object.new)
    @it.send("#{@attribute}").should be_false
  end
  
  it 'should convert number assigments besides 1 to false' do
    [45, -4.5, 0,1000000].each do |number|
      @it.send("#{@attribute}=",number)
      @it.send("#{@attribute}").should be_false
    end
  end
  
  it 'should be valid for true' do
    @it.send("#{@attribute}=",true)
    @it.should be_valid
  end
  
  it 'should be valid for false' do
    @it.send("#{@attribute}=",false)
    @it.should be_valid
  end
end

shared_examples_for 'an ActiveRecord-customized datetime' do
  it 'should be valid for a valid DateTime object' do
    @it.send("#{@attribute}=",DateTime.now)
    @it.should be_valid
  end
  
  it 'should be valid for a valid Time object' do
    @it.send("#{@attribute}=",Time.now)
    @it.should be_valid
  end
  
  it "should convert string assignments to nil" do
    ["cat", "helloooo", "tru", ""].each do |string|
      @it.send("#{@attribute}=",string)
      @it.send("#{@attribute}").should be_nil
    end
  end
  
  it 'should not be valid for empty arrays' do
    @it.send("#{@attribute}=",[])
    @it.should_not be_valid
  end
  
  it 'should not be valid for empty hashes' do
    @it.send("#{@attribute}=",{})
    @it.should_not be_valid
  end
  
  it 'should not be valid for objects' do
    @it.send("#{@attribute}=",Object.new)
    @it.should_not be_valid
  end
  
  it 'should not be valid for numbers' do
    [45, -4.5, 0,1000000].each do |number|
      #A new dataset is created each time for this test because of a strange 
      #     behavior where assignment no longer works after the 
      #     firt assignment to when_last_queried
      @it = FactoryGirl.build(@it.class.to_s.downcase)
      @it.send("#{@attribute}=",number)
      @it.should_not be_valid
    end
  end
end

shared_examples_for 'an ActiveRecord-customized integer >= 0' do
  it 'should be valid when it is 0 or higher' do
    [0, 1, 5, 1000000].each do |non_negative_integer|
      @it.send("#{@attribute}=", non_negative_integer)
      @it.should be_valid
    end
  end
  
  it 'should not be valid when it is below 0' do
    [-1, -5, -1000000].each do |zero_or_negative_integer|
      @it.send("#{@attribute}=", zero_or_negative_integer)
      @it.should_not be_valid
    end
  end
  
  it 'should not be valid when a non-numeric string' do
    ['kittens', ""].each do |string|
      @it.send("#{@attribute}=", string)
      @it.should_not be_valid
    end
  end
  
  it 'should convert quoted numerics to regular numeric' do
    ['0',"4.5", '62'].each do |numeric_string|
      @it.send("#{@attribute}=", numeric_string)
      @it.send("#{@attribute}").should eq(numeric_string.to_i)
    end
  end
  
  it 'should convert true to 1' do
    @it.send("#{@attribute}=", true)
    @it.send("#{@attribute}").should eq(1)
  end
  
  it 'should convert false to 0' do
    @it.send("#{@attribute}=", false)
    @it.send("#{@attribute}").should eq(0)
  end
  
  it 'should convert "true" to 0' do
    @it.send("#{@attribute}=", "true")
    @it.send("#{@attribute}").should eq(0)
  end
  
  it 'should convert "false" to 0' do
    @it.send("#{@attribute}=", "false")
    @it.send("#{@attribute}").should eq(0)
  end
end

shared_examples_for 'a number' do  
  it 'should not be valid when a non-numeric string' do
    ['kittens', "true","false"].each do |string|
      @it.send("#{@attribute}=", string)
      @it.send(@attribute).should eq(0)
    end
  end
  
  it 'should be valid for numeric strings' do
    ['-5','0',"4.5", '62'].each do |numeric_string|
      @it.send("#{@attribute}=", numeric_string)
      @it.should be_valid
    end
  end
  
  it 'should be valid for numbers' do
     [-5,0,4.5,62].each do |number|
      @it.send("#{@attribute}=", number)
      @it.should be_valid
    end
  end
  
  it 'should be able to store large numbers' do
     @it.send("#{@attribute}=", 1e300)
     @it.save!
     @it.reload
     @it.send("#{@attribute}").should eq(1e300)
  end
end

shared_examples_for 'a required attribute' do
  it 'should be required' do
    @it.send("#{@attribute}=", nil)
    @it.should_not be_valid
  end
end

shared_examples_for 'an optional attribute' do
  it 'should be optional' do
    @it.send("#{@attribute}=", nil)
    @it.should be_valid
  end
end

