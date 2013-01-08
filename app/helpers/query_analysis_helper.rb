module QueryAnalysisHelper
  def ascending_sort_arrow
    return image_tag('ascending_sort_arrow.png', :class => 'sort_arrow')
  end
  
  def descending_sort_arrow
    return image_tag('descending_sort_arrow.png', :class => 'sort_arrow')
  end
  
  def neutral_sort_arrow
    return image_tag('neutral_sort_arrow.png', :class => 'sort_arrow')
  end
  
  def link_to_fasta_sequence_for_transcript(dataset_id, transcript_name)
    link_address = "get_transcript_fasta?" +
                   "dataset_id=#{dataset_id}&" +
                   "transcript_name=#{transcript_name}"
    return link_to(transcript_name, link_address, :target => '_blank')
  end
  
  def link_to_fasta_sequences_for_gene(dataset_id, gene_name)
    link_address = "get_gene_fastas?" +
                   "dataset_id=#{dataset_id}&" +
                   "gene_name=#{gene_name}"
    return link_to(gene_name, link_address, :target => '_blank')
  end
  
  def link_to_amigo_web_page_for_term(body,go_id)
    link_address = "http://amigo.geneontology.org/" +
                   "cgi-bin/amigo/term_details?term=#{go_id}"
    return link_to(body, link_address, :target => '_blank')
  end
  
  def link_to_ncbi_search_for(search_term)
    link_address = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?" +
                   "db=nucleotide&cmd=search&term=#{search_term}"
    return link_to search_term, link_address         
  end
  
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
end
