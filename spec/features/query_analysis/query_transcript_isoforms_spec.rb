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
    visit 'query_analysis/query_transcript_isoforms'
    find_button('submit_query').click
    dataset_id = find('#query_transcript_isoforms_dataset_id').value
    dataset = Dataset.find_by_id(dataset_id)
    #debugger
    all_rows = all('#query_results_table tbody tr')
    (0..all_rows.count-1).each do |n|
      tr = all_rows[n]
      tds = tr.all('td')
      visit(URI.escape(tds[0].find('a')[:href]))
      visit(URI.escape(tds[1].find('a')[:href]))
      
      transcript_name = tds[0].text
      transcript_name.should eq(dataset.transcripts[n].name_from_program)
      transcript = Transcript.where(:dataset_id => dataset_id, 
                                    :name_from_program => transcript_name)[0]
      gene_name = tds[1].text
      gene_name.should eq(transcript.gene.name_from_program)
      
      #tds.each do |td|
        
        #print page.html
        #verify contents of each cell
        #td.text.should eq('Tristin Cartwright')
        #Verify transcript and gene link text but test the fasta sequnce somewhere else?
        #td.should have_link(td.text, :href => 'get_transcript_fasta?dataset_id=1&transcript_name=Transcript_0')
      #end
    end
#     visit 'http://google.com'
#     #click_button 'query'
#     response.should have_selector('table')
  end
  
  it 'should test table sorting'
  
  it 'should fail gracefully when not datasets or samples are available'
  
  it 'should fail gracefully when no samples are available?'
end
