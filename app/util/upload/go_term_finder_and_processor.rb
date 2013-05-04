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
      (transcript_name, go_accession) = line.strip.match(line_regex).captures
      go_term = GoTerm.find_by_acc(go_accession)
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
    Rails.logger.info "Running blastx for dataset: #{@dataset.id}"
    @blast_xml_output_file = Tempfile.new('blastx')
    @blast_xml_output_file.close
#    SystemUtil.system!("#{Rails.root}/bin/blast2go/run_blastx_for_blast2go.pl " +
#                       "#{@transcripts_fasta_file.path} " +
#                       "#{@blast_xml_output_file.path}")
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
    blast2go_output_file = Tempfile.new('blast2go')
    blast2go_output_file.close
    blast2go_dir = "#{Rails.root}/bin/blast2go"
    SystemUtil.system!("java -Xmx2000m " +
                      "-cp *:#{blast2go_dir}/ext/*:#{blast2go_dir}/* " +
                      "es.blast2go.prog.B2GAnnotPipe " +
                      "-in #{@blast_xml_output_file.path} " +
                      "-out #{blast2go_output_file.path} " +
                      "-prop #{blast2go_dir}/b2gPipe.properties -annot")
    Rails.logger.info "Finished blast2go for dataset: #{@dataset.id}"
    #Delete the temporary files
    File.delete(@blast_xml_output_file.path)
    File.delete(blast2go_output_file.path)
    #Return the path of the resulting file containing the go terms
    return "#{blast2go_output_file.path}.annot"
  end
end
