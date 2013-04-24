require 'upload/trinity_fpkm_file_processor.rb' 

class TrinityGeneFpkmFileProcessor < TrinityFpkmFileProcessor
  def process_file()
    while not @uploaded_fpkm_file.eof?
      fpkm_line = @uploaded_fpkm_file.get_next_line
      next if fpkm_line.nil?
      gene = Gene.where(:dataset_id => @dataset.id,
                        :name_from_program => fpkm_line.item).first
      #Don't get the fpkms for transcripts with no differential expression tests
      next if gene.nil? 
      set_fpkms_for_item(gene, fpkm_line)
    end
  end
end
