# Contains helpers for the QueryAnalysisController
module QueryAnalysisHelper
  # Displays an ascending sort arrow used for table sorting
  def ascending_sort_arrow
    return image_tag('ascending_sort_arrow.png', :class => 'sort_arrow')
  end
  
  # Displays a descending sort arrow used for table sorting
  def descending_sort_arrow
    return image_tag('descending_sort_arrow.png', :class => 'sort_arrow')
  end
  
  # Displays link to the fasta sequence for a given transcript name in a 
  # given dataset.
  def link_to_fasta_sequence_for_transcript(dataset_id, transcript_name)
    link_address = "get_transcript_fasta?" +
                   "dataset_id=#{dataset_id}&" +
                   "transcript_name=#{URI.encode(transcript_name)}"
    return link_to(transcript_name, link_address, :target => '_blank')
  end
  
  # Displays link to the fasta sequences for the transcripts for a given 
  # gene name in a given dataset.
  def link_to_fasta_sequences_for_gene(dataset_id, gene_name)
    link_address = "get_gene_fastas?" +
                   "dataset_id=#{dataset_id}&" +
                   "gene_name=#{gene_name}"
    return link_to(gene_name, link_address, :target => '_blank')
  end
  
  # Displays a link to the Gene Onotology website for the specified go_id 
  # having the text specified in body.
  def link_to_amigo_web_page_for_term(body,go_id)
    link_address = "http://amigo.geneontology.org/" +
                   "cgi-bin/amigo/term_details?term=#{go_id}"
    return link_to(body, link_address, :target => '_blank')
  end
  
  # Displays a link to the NCBI search website for the specified search term
  def link_to_ncbi_search_for(search_term)
    link_address = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?" +
                   "db=nucleotide&cmd=search&term=#{search_term}"
    return link_to search_term, link_address         
  end
  
  # Returns a color based on the specified blast score
  def get_color_for_score(score)
    if score < 40
      color = 'black'
    elsif score >= 40 && score < 50
      color = 'blue'
    elsif score >= 50 && score < 80
      color = 'lime'
    elsif score >= 80 && score < 200
      color = 'magenta'
    elsif score >= 200
      color = 'red'
    end
    return color
  end
  
  # Returns the starting width percent page needed for some calculations on 
  # the blast results page.
  def get_start_width_percent(hsp)
    return (hsp.query_from == 1 ) ? 0 : (hsp.query_from/_1_percent-1)
  end
  
  # Returns the ending width percent page needed for some calculations on 
  # the blast results page.
  def get_end_width_percent(hsp)
    return (hit.query_to/_1_percent) - get_start_width_percent(hsp) - 1
  end
  
  #Returns a tooltip to use for hsps in the blast graphical summary
  def get_tooltip(hit, hsp)
    return ">#{hit.hit_id} #{hit.target_def}\nBit score=#{hit.bit_score} E-value=#{hit.evalue}"
  end
  
 # Returns a unique html id for a blast result hit that can be used to link 
 # directly to the hit
 def get_unique_hit_id(report,iteration,hit)
   return "Report-#{report.query_id},Iteration-#{iteration.num},Hit-#{hit.num}"
 end
end
