require 'spec_helper'
#require 'rails/commands'

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
  
  #TODO
#   it 'should have all the columns in the query results table ' +
#      'be sortable', :js => true do
#     visit 'query_analysis/query_transcript_isoforms'
#     find_button('submit_query').click
#     ths = all('#query_results_table thead tr th')
#     ths[3].click
#     all('#query_results_table tbody tr')[0].all('td')[3].text.should eq('-')
#     #save_and_open_page
#   end
  
  it 'should provide links to the Gene Ontology website for each GO term',
      :js => true do
    #Go to page and submit the query
    visit 'query_analysis/query_transcript_isoforms'
    find_button('submit_query').click
    #Store the dataset and fpkm sample for later use
    dataset_id = find('#query_transcript_isoforms_dataset_id').value
    dataset = Dataset.find_by_id(dataset_id)
    #Verify all the rows in the query results table by looping through them
    all_rows = all('#query_results_table tbody tr')
    all_rows.count.should eq(dataset.transcripts.count)
    original_window_handle = page.driver.browser.window_handles.first
    (0..all_rows.count-1).each do |n|
      #Extract some variables to use below
      tr = all_rows[n]
      tds = tr.all('td')
      transcript = dataset.transcripts[n]
      #Verify the GO terms and their links for the transcript
      if transcript.go_terms.empty?
        tds[2].text.should eq('No GO ids found.')
      else
        #Verify all the go terms by looping through them
        go_items = tds[2].all('li')
        (0..go_items.count-1).each do |i|
          #Extract some variables
          html_go_item = go_items[i].text
          go_id = transcript.go_terms[i].id
          required_href = "http://amigo.geneontology.org/" +
                          "cgi-bin/amigo/term_details?" +
                          "term=#{go_id}"
          #Verify the link href is correct
          go_link = go_items[i].find('a')
          go_link[:href].should eq(required_href)
          #Verify the link goes to the right place by clicking it and examining
          #     the page's contents
          go_link.click
          go_link_window_handle = page.driver.browser.window_handles.last
          page.driver.browser.switch_to.window(go_link_window_handle)
          expected_page_title = "AmiGO: Term Details for #{go_id}"
          page.find('title').text.should eq(expected_page_title)
          page.driver.browser.switch_to.window(original_window_handle)
        end
      end
    end
  end
  
  it 'should provide links to each transcript fasta sequence' do
    #Go to page and submit the query
    visit 'query_analysis/query_transcript_isoforms'
    find_button('submit_query').click
    #Store the dataset id for later use
    dataset_id = find('#query_transcript_isoforms_dataset_id').value
    #Verify all the rows in the query results table by looping through them
    (all('#query_results_table tbody tr')).each do |tr|
      #Extract some variables to use below
      tds = tr.all('td')
      transcript = Transcript.where(:dataset_id => dataset_id,
                                    :name_from_program => tds[0].text)[0]
      #Verify the transcript's link looks correct
      transcript_href = URI.escape("get_transcript_fasta?" +
                        "dataset_id=#{dataset_id}" +
                        "&transcript_name=#{tds[0].text}")
      tds[0].should have_link(tds[0].text, :href => transcript_href)
      #Verify the link goes to a page that at least looks kind of like the 
      #    transcript's fasta
      tds[0].find('a').click
      transcript_fasta_regex = 
          /\A>#{Regexp.escape(transcript.blast_seq_id)}.+\n([atcg]+\n)+\z/i
      page.html.should match(transcript_fasta_regex)
    end
  end
  
  it "should provide a link to the fastas for the gene's transcripts" do
    #Go to page and submit the query
    visit 'query_analysis/query_transcript_isoforms'
    find_button('submit_query').click
    #Store the dataset id for later use
    dataset_id = find('#query_transcript_isoforms_dataset_id').value
    #Verify all the rows in the query results table by looping through them
    all('#query_results_table tbody tr').each do |tr|
      #Extract some variables to use below
      tds = tr.all('td')
      gene = Gene.where(:dataset_id => dataset_id,
                        :name_from_program => tds[1].text)[0]
      #Verify the gene's link looks correct
      gene_href = URI.escape("get_gene_fastas?dataset_id=#{dataset_id}" +
          "&gene_name=#{tds[1].text}")
      tds[1].should have_link(tds[1].text, :href => gene_href)
      #Verify the link goes to a page that at least looks kind of like the 
      #    the fastas for the gene's transcripts
      tds[1].find('a').click
      transcript_fasta_scan_regex = 
          />.+\n(?:[atcg]+\n)+/i
      transcript_fastas = page.html.scan(transcript_fasta_scan_regex)
      transcript_fastas.count.should eq(gene.transcripts.count)
      (0..gene.transcripts.count-1).each do |i|
        transcript = gene.transcripts[i]
        transcript_fasta_regex = 
          /\A>#{Regexp.escape(transcript.blast_seq_id)}.+\n([atcg]+\n)+\z/i
        transcript_fastas[i].should match(transcript_fasta_regex)
      end
    end
  end
  
  #TODO
  it 'should allow the query results table to be downloadable as a text file'
  
  it 'should fail gracefully when not datasets or samples are available'
  
  it 'should fail gracefully when no samples are available?'
  
  describe 'query filtering' do
    
    #MAYBE TODO:Put the requirements that this test satisfies here??
    it 'should show everything when no filtering options are selected' do
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
        #Verify the gene name
        tds[1].text.should eq(transcript.gene.name_from_program)
        #Verify the GO terms and their links for the transcript
        if transcript.go_terms.empty?
          tds[2].text.should eq('No GO ids found.')
        else
          #Verify all the go terms by looping through them
          go_items = tds[2].all('li')
          (0..go_items.count-1).each do |i|
            #Extract some variables
            html_go_item = go_items[i].text
            #Verify the go term
            html_go_item.should include(transcript.go_terms[i].term)
            #Verify the go id
            html_go_item.should include(transcript.go_terms[i].id)
          end
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
      end
    end
    
    #TODO
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
