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
  
  it 'should display a failure message if any of the parameters are invalid'
  
  it 'should have all the columns in the query results table ' +
     'be sortable', :js => true do
    visit 'query_analysis/query_transcript_isoforms'
    puts "HTML=" + page.html
    find_button('submit_query').click
    ths = all('#query_results_table thead tr th')
    ths[3].click
    all('#query_results_table tbody tr')[0].all('td')[3].text.should eq('-')
    #save_and_open_page
  end
  
  it 'should all the query results table to be downloadable as a text file'
  
  it 'should fail gracefully when not datasets or samples are available'
  
  it 'should fail gracefully when no samples are available?'
  
  describe 'query filtering' do
    
    #MAYBE TODO:Put the requirements that this test satisfies here??
    it 'should show everything when no filtering options are selected', :js => true do
      #Go to page and submit the query
      visit 'query_analysis/query_transcript_isoforms'
      find_button('submit_query').click
      #Store the dataset and fpkm sample for later use
      dataset_id = find('#query_transcript_isoforms_dataset_id').value
      dataset = Dataset.find_by_id(dataset_id)
      sample_id = find('#query_transcript_isoforms_sample_id').value
      #Verify all the rows in the query results table by looping through them
      all_rows = all('#query_results_table tbody tr')
      all_rows.count.should eq(dataset.transcripts.count)
      (0..all_rows.count-1).each do |n|
        #Extract some variables to use below
        tr = all_rows[n]
        tds = tr.all('td')
        transcript = dataset.transcripts[n]
        transcript_info = transcript.transcript_fpkm_tracking_information
        fpkm_sample = FpkmSample.where(:sample_id => sample_id,
                                       :transcript_id => transcript.id)[0]
        #Verify the transcript name
        tds[0].text.should eq(transcript.name_from_program)
        #Verify the transcript's link
        transcript_href = URI.escape("get_transcript_fasta?" +
                          "dataset_id=#{dataset_id}" +
                          "&transcript_name=#{tds[0].text}")
        tds[0].should have_link(tds[0].text, :href => transcript_href)
        tds[0].find('a').click
        #Verify the gene name
        tds[1].text.should eq(transcript.gene.name_from_program)
        #Verify the gene's link
        gene_href = URI.escape("get_gene_fastas?dataset_id=#{dataset_id}" +
                    "&gene_name=#{tds[1].text}")
        tds[1].should have_link(tds[1].text, :href => gene_href)
        #visit(URI.escape(tds[1].find('a')[:href]))
        #Verify the GO ids
#         if transcript.go_terms.empty?
#           tds[2].text.should eq('No GO ids found.')
#         else
#           go_ids = tds[2].text.scan(/\[(GO:\d+)\]/).flatten.sort
#           go_ids.count.should eq(transcript.go_terms.count)
#           sorted_go_ids = go_ids.sort
#           (0..go_ids.count-1).each do |n|
#             sorted_go_ids[n].should eq(transcript.go_terms[n].id)
#           end
#         end
        #Verify the GO links
        tds[2].all('a').each do |a|
          a.click
        end
        #Verify the class code
        tds[3].text.should eq(transcript_info.class_code)
        #Verify the transcript length
        tds[4].text.to_i.should eq(transcript_info.length)
        #Verify the coverage
        tds[5].text.to_d.round(3).should eq(transcript_info.coverage.round(3))
        #Verify the fpkm
        tds[6].text.to_d.round(3).should eq(fpkm_sample.fpkm.round(3))
        #Verfiy the fpkm lower bound
        tds[7].text.to_d.round(3).should eq(fpkm_sample.fpkm_lo.round(3))
        #Verify the fpkm upper bound
        tds[8].text.to_d.round(3).should eq(fpkm_sample.fpkm_hi.round(3))
        #Verify the quantification status
        tds[9].text.should eq(fpkm_sample.status)
          #print page.html
      end
    end
    
    it 'should filter by class code ='
    
    it 'should filter by class code c'
    
    it 'should filter by class code j'
    
    it 'should filter by class code e'
    
    it 'should filter by class code i'
    
    it 'should filter by class code o'
    
    it 'should filter by class code p'
    
    it 'should filter by class code r'
    
    it 'should filter by class code u'
    
    it 'should filter by class code x'
    
    it 'should filter by class code s'
    
    it 'should filter by class code .'
    
    it 'should filter by all class codes'
    
    it 'should filter by GO names'
    
    it 'should filter by GO IDs'
    
    it 'should filter by transcript name'
    
    it 'should filter by greater than transcript length'
    
    it 'should filter by greater than or equal to transcript length'
    
    it 'should fitler by less than transcript length'
    
    it 'should filter by less than or equal to transcript length'
    
    it 'should filter by equal to transcript length'
  end 
end
