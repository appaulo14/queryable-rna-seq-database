require 'open3'
require 'system_util'

###
# Utility class to find the Gene Ontology (GO) terms for a dataset and 
# store them in the database.
class GoTermFinderAndProcessor
  ###
  # parameters::
  # * <b>transcripts_fasta_file:</b> The fasta file needed to find the go terms
  # * <b>dataset:</b> the dataset to find the go terms for
  def initialize(transcripts_fasta_file,dataset)
    @transcripts_fasta_file = transcripts_fasta_file
    @dataset = dataset
  end
  
  ###
  # Finds the go terms by running blastx and blast2go
  def find_go_terms()
    run_blastx()
    @go_terms_file_path = run_blast2go()
  end
  
  ###
  # Saves the go terms found in the find_go_terms method to the database
  def process_go_terms()
    go_terms_file = File.open(@go_terms_file_path)
    while not go_terms_file.eof?
      line = go_terms_file.readline
      next if line.blank?
      #Remove from the transcript name the "lcl|" part put there by blast
      line.gsub!(/\Alcl\|/,'')
      line_regex = /\A(\S+)\s+(\S+)\s+(.+)\z/
      (transcript_name, go_id) = line.strip.match(line_regex).captures
      go_term = GoTerm.find_by_id(go_id)
      # If the go term doesn't currently exist in the rails database, 
      # copy it from the Blast2go database
      if go_term.nil?
        b2gdb_go_term = B2gdbGoTerm.find_by_acc(go_id)
        go_term = GoTerm.create!(:id => b2gdb_go_term.acc,
                                 :term => b2gdb_go_term.name)
      end
      transcript = Transcript.where(:dataset_id => @dataset.id, 
                                     :name_from_program => transcript_name)[0]
      TranscriptHasGoTerm.create!(:transcript => transcript, 
                                     :go_term => go_term)
    end
    go_terms_file.close
    # Clean up the files now that everything is finished
    cleanup_files()
  end
  
  private
  
  def run_blastx
    #Run blastx
    Rails.logger.info "Running blastx for dataset: #{@dataset.id}"
    @blast_xml_output_file = Tempfile.new('blastx')
    @blast_xml_output_file.close
    SystemUtil.system!("#{Rails.root}/bin/blast/bin/blastx " +
                        "#{BLAST_CONFIG['is_remote']} " +
                        "-db #{BLAST_CONFIG['db']} " +
                        "-query #{@transcripts_fasta_file.path} " +
                        "-out #{@blast_xml_output_file.path} " +
                        "-show_gis -outfmt '5' -evalue 1e-6")
    Rails.logger.info "Finished blastx for dataset: #{@dataset.id}"
  end
  
  def run_blast2go
    Rails.logger.info "Running blast2go for dataset: #{@dataset.id}"
    @blast2go_output_file = Tempfile.new('blast2go')
    @blast2go_output_file.close
    blast2go_dir = "#{Rails.root}/bin/blast2go"
    SystemUtil.system!("java -Xmx2000m " +
                      "-cp *:#{blast2go_dir}/ext/*:#{blast2go_dir}/* " +
                      "es.blast2go.prog.B2GAnnotPipe " +
                      "-in #{@blast_xml_output_file.path} " +
                      "-out #{@blast2go_output_file.path} " +
                      "-prop #{blast2go_dir}/b2gPipe.properties -annot")
    Rails.logger.info "Finished blast2go for dataset: #{@dataset.id}"
    #Return the path of the resulting file containing the go terms
    return "#{@blast2go_output_file.path}.annot"
  end
  
  def cleanup_files()
    File.delete(@blast_xml_output_file.path)
    File.delete(@go_terms_file_path)
    File.delete(@blast2go_output_file.path)
  end
end
