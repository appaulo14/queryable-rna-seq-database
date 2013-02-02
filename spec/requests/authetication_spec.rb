require 'spec_helper'

describe 'Authentication' do
  describe 'Sign in/Sign Out' do
    it 'should sign in and sign out a valid user' do
      user = FactoryGirl.create(:user)
      sign_in(user)
      controller.should be_signed_in
      sign_out()
      conroller.should_not be_signed_in
    end
  end
  
  describe 'Edit Registration' do
  end
end
