require 'upload/trinity_fpkm_file_processor.rb' 

class TrinityTranscriptFpkmFileProcessor < TrinityFpkmFileProcessor
  
  def process_file()
    while not @uploaded_fpkm_file.eof?
      fpkm_line = @uploaded_fpkm_file.get_next_line
      next if fpkm_line.nil?
      transcript = Transcript.where(:dataset_id => @dataset.id,
                                     :name_from_program => fpkm_line.item).first
      #Don't get the fpkms for transcripts with no differential expression tests
      next if transcript.nil? 
      set_fpkms_for_item(transcript, fpkm_line)
    end
  end
end
