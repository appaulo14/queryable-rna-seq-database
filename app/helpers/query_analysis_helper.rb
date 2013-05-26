# Contains helpers for the QueryAnalysisController
module QueryAnalysisHelper  
  # Displays a link to the fasta sequence for a given transcript name in a 
  # given dataset.
  def link_to_fasta_sequence_for_transcript(dataset_id, transcript_name)
    link_address = "get_transcript_fasta?" +
                   "dataset_id=#{dataset_id}&" +
                   "transcript_name=#{URI.encode(transcript_name)}"
    return link_to(transcript_name, link_address, :target => '_blank')
  end
  
  # Displays a link to the fasta sequences for the transcripts for a given 
  # gene name in a given dataset.
  def link_to_fasta_sequences_for_gene(dataset_id, gene_name)
    link_address = "get_gene_fastas?" +
                   "dataset_id=#{dataset_id}&" +
                   "gene_name=#{gene_name}"
    return link_to(gene_name, link_address, :target => '_blank')
  end
  
  ###
  # Displays a link to the Amigo page for the given go term/go id.
  def link_to_amigo_web_page_for_term(go_term,go_id)
    go_term = go_term.strip()
    go_id = go_id.strip()
    body = "#{go_term} [#{go_id}]"
    address = "http://amigo.geneontology.org/" +
                   "cgi-bin/amigo/term_details?term=#{go_id}"
    return link_to(body, address, :target => '_blank')
  end
  
  # Displays a link to the NCBI search website for the specified search term
  def link_to_ncbi_search_for(search_term)
    link_address = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?" +
                   "db=nucleotide&cmd=search&term=#{search_term}"
    return link_to search_term, link_address         
  end
end
