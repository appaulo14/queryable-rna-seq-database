require 'spec_helper'

describe 'Query Transcript Isoforms page' do
  before(:each) do
    #user = FactoryGirl.create(:user)
    #sign_in(user)
    sign_in_as_nietz111
  end
  
  it 'should redirect users who are not signed in to the home page'
  
  it 'should goat' do
    lambda do
      visit 'query_analysis/query_transcript_isoforms'
      find_button('submit_query').click
      all('#query_results_table tbody tr').each do |tr|
        tr.all('td').each do |td|
          #verify contents of each cell
        end
      end
      response.should have_selector("div.flash.success",
                                    :content => "Welcome")
    end.should change(User, :count).by(1)
#     visit 'http://google.com'
#     #click_button 'query'
#     response.should have_selector('table')
  end
  
  it 'should fail gracefully when not datasets or samples are available'
  
  it 'should fail gracefully when no samples are available?'
end
