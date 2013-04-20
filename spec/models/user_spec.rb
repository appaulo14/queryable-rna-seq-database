# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  name                   :string(255)      not null
#  description            :text             default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  admin                  :boolean          default(FALSE), not null
#

require 'spec_helper'
require 'models/shared_examples.rb'

# NOTE: Most of the functionality for the User model class is provided by the 
# Devise gem. Therefore, I only tests the attributes that were added by me.
describe User do
  before (:each) do
    @it = FactoryGirl.build(:user)
  end

  describe 'associations', :type => :associations do
    it 'should have a datasets attribute' do
      @it.should respond_to(:datasets)
    end
  end
  
  describe 'when destroyed' do
    before (:each) do @it.save! end
    
    it 'should destroy the dependent datasets' do
      FactoryGirl.create(:dataset, :user => @it)
      FactoryGirl.create(:dataset, :user => @it)
      Dataset.find_all_by_user_id(@it.id).count.should eq(2)
      @it.destroy
      Dataset.find_all_by_user_id(@it.id).should be_empty
    end
  end
  
  describe 'validations' do
    it 'should save successfully when valid' do
      @it.save!
    end
    
    describe 'email' do
      before (:each) do @attribute = 'email' end
      
      it 'should be invalid for non .edu addresses' do
        ['a@yahoo.net','a@gmail.com'].each do |invalid_email|
          @it.email = invalid_email
          @it.should_not be_valid
        end
      end
      
      it 'should be valid for .edu addresses' do
        ['a@ksu.edu','a@ku.edu'].each do |valid_email|
          @it.email = valid_email
          @it.should be_valid
        end
      end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'name' do
      before (:each) do @attribute = 'name' end
      
      it_should_behave_like 'a required attribute'
    end
    
    describe 'description' do
      before (:each) do @attribute = 'description' end
      
      it_should_behave_like 'a required attribute'
    end 
  end
end
