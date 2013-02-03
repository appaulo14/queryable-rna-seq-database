require 'spec_helper'

describe 'Query Transcript Isoforms page' do
  before(:each) do
    #user = FactoryGirl.create(:user)
    #sign_in(user)
    sign_in_as_nietz111
  end
  
  it 'should redirect users who are not signed in to the home page'
  
  it 'should only display datasets which belong to the user and ' +
     'have transript isoform data'
  
  it 'should goat' do
    lambda do
      visit 'query_analysis/query_transcript_isoforms'
      find_button('submit_query').click
      all('#query_results_table tbody tr').each do |tr|
        tds = tr.all('td')
        #tds.each do |td|
          visit(URI.escape(tds[0].find('a')[:href]))
          visit(URI.escape(tds[1].find('a')[:href]))
          #print page.html
          #verify contents of each cell
          #td.text.should eq('Tristin Cartwright')
          #Verify transcript and gene link text but test the fasta sequnce somewhere else?
          #td.should have_link(td.text, :href => 'get_transcript_fasta?dataset_id=1&transcript_name=Transcript_0')
        #end
      end
    end.should change(User, :count).by(1)
#     visit 'http://google.com'
#     #click_button 'query'
#     response.should have_selector('table')
  end
  
  it 'should test table sorting'
  
  it 'should fail gracefully when not datasets or samples are available'
  
  it 'should fail gracefully when no samples are available?'
end
