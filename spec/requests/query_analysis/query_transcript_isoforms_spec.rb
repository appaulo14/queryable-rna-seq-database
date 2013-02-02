require 'spec_helper'
require 'rspec/rails'
require 'rspec/autorun'

describe 'Query Transcript Isoforms page', :js => true do
  before(:each) do
    #user = FactoryGirl.create(:user)
    #sign_in(user)
    sign_in_as_nietz111
  end
  
  it 'should redirect users who are not signed in to the home page'
  
  it 'should goat' do
    lambda do
      visit 'query_analysis/query_transcript_isoforms'
      click_button
      response.should have_selector("div.flash.success",
                                    :content => "Welcome")
    end.should change(User, :count).by(1)
#     visit 'http://google.com'
#     #click_button 'query'
#     response.should have_selector('table')
  end
  
  it 'should fail gracefully when not datasets or samples are available'
end
