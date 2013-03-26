require 'open3'

class GoTermFinderAndProcessor
  def initialize(uploaded_file,dataset)
    @uploaded_transcripts_file = uploaded_file
    @dataset = dataset
  end
  
  def find_go_terms()
    run_blastx()
    @go_terms_file_path = run_blast2go()
  end
  
  def process_go_terms()
    go_terms_file = File.open(@go_terms_file_path)
    while not go_terms_file.eof?
      line = go_terms_file.readline
      next if line.blank?
      line_regex = /\A(\S+)\s+(\S+)\s+(.+)\z/
      (transcript_name, go_id, term) = line.strip.match(line_regex).captures
      go_term = GoTerm.find_by_id(go_id)
      if go_term.nil?
        go_term = GoTerm.create!(:id => go_id, :term => term)
      end
      transcript = Transcript.where(:dataset_id => @dataset.id, 
                                    :name_from_program => transcript_name)[0]
      TranscriptHasGoTerm.create!(:transcript => transcript, 
                                     :go_term => go_term)
    end
    go_terms_file.close
    File.delete(go_terms_file.path)
  end
  
  private
  
  def run_blastx
    #Run blastx
    logger.info "Running blastx for dataset: #{@dataset.id}"
    @blast_xml_output_file = Tempfile.new('blastx')
    @blast_xml_output_file.close
    stdout, stderr, status = 
      Open3.capture3("#{Rails.root}/bin/blast/bin/blastx " +
                    "-remote -db nr " +
                    "-query #{@uploaded_transcripts_file.tempfile.path} " +
                    "-out #{@blast_xml_output_file.path} " +
                    "-show_gis -outfmt '5' -evalue 1e-6")
    #Raise an exception if there were errors with blastx
    if not stderr.blank?
      raise StandardError, stderr
    end
    logger.info "Finished blastx for dataset: #{@dataset.id}"
  end
  
  def run_blast2go
    logger.info "Running blast2go for dataset: #{@dataset.id}"
    blast2go_output_file = Tempfile.new('blast2go')
    blast2go_output_file.close
    blast2go_dir = "#{Rails.root}/bin/blast2go"
    stdout, stderr, status = 
      Open3.capture3("java -Xmx2000m " +
                      "-cp *:#{blast2go_dir}/ext/*:#{blast2go_dir}/* " +
                      "es.blast2go.prog.B2GAnnotPipe " +
                      "-in #{@blast_xml_output_file.path} " +
                      "-out #{blast2go_output_file.path} " +
                      "-prop #{blast2go_dir}/b2gPipe.properties -annot")
    #Raise an exception if there were errors with blast2go
    if not stderr.blank?
      raise StandardError, stderr
    end
    logger.info "Finished blast2go for dataset: #{@dataset.id}"
    #Delete the temporary files
    File.delete(@blast_xml_output_file.path)
    File.delete(blast2go_output_file.path)
    #Return the path of the resulting file containing the go terms
    return "#{blast2go_output_file.path}.annot"
  end
end
