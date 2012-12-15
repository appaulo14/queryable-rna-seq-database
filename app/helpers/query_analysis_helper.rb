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
end
