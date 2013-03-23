class Blast2go_Runner
  require 'tempfile'
  
  def run_blast2go 
    blast_xml_output_file = Tempfile.new('blastx')
    blast_xml_output_file.close
    system("~/Ruby_Workshop/rails_projects/queryable_rna_seq_database/bin/blast/bin/blastx " +
          "-remote -db nr -query 10Seqs.fasta -out #{blast_xml_output_file.path} " +
          "-show_gis -outfmt '5' ")
    blast2go_output_file = Tempfile.new('blast2go')
    blast2go_output_file.close
    system("java -Xmx4000m -cp *:ext/*: es.blast2go.prog.B2GAnnotPipe -in #{blast_xml_output_file.path} -out #{blast2go_output_file.path} -prop b2gPipe.properties -annot")
    f=File.open("#{blast2go_output_file.path}.annot}")
    while not f.eof?
      line = f.readline
      (transcript_name, go_id, term) = line.split(/\s+/)
      go_term = GoTerm.find_by_id(go_id)
      if (go_term.nil?)
        GoTerm.create!(:id=>go_id,:term => term)
      end
      transcript = Transcript.where(:dataset_id => dataset.id, :name_from_program => name_from_program)
      TranscriptHasGoTerm.new(:transcript => transcript, go_term => go_term)
    end
    f.close
    blast_xml_output_file.delete
    blast2go_output_file.delete
  end
end
