class UploadUtil
  require 'system_util.rb'
  require 'open3'
  
  def self.create_blast_database(fasta_file_path, dataset)
    SystemUtil.system!("#{Rails.root}/bin/blast/bin/makeblastdb " +
                        "-in #{fasta_file_path} " +
                        "-title #{dataset.id} " +
                        "-out #{dataset.blast_db_location} " +
                        "-hash_index -parse_seqids -dbtype nucl ")
  end
  
  def self.rollback_blast_database(dataset)
    stdout, stderr, status = 
      Open3.capture3("ls db/blast_databases/#{Rails.env}/#{dataset.id}.*")
    if stderr.blank?
      system("rm db/blast_databases/#{Rails.env}/#{dataset.id}.*")
    end
  end
  
  def self.generate_go_terms(fasta_file_path)
    #Run blastx
    blast_xml_output_file = Tempfile.new('blastx')
    blast_xml_output_file.close
    stdout, stderr, status = 
      Open3.capture3("#{Rails.root}/bin/blast/bin/blastx " +
                    "-remote -db nr " +
                    "-query #{fasta_file_path} " +
                    "-out #{blast_xml_output_file.path} " +
                    "-show_gis -outfmt '5' ")
    #Raise an exception if there were errors with blastx
    if not stderr.blank?
      raise StandardError, stderr
    end
    #Run blast2go
    blast2go_output_file = Tempfile.new('blast2go')
    blast2go_output_file.close
    blast2go_dir = "#{Rails.root}/bin/blast2go"
    stdout, stderr, status = 
      Open3.capture3("java -Xmx4000m " +
                      "-cp *:#{blast2go_dir}/ext/*:#{blast2go_dir}/* " +
                      "es.blast2go.prog.B2GAnnotPipe " +
                      "-in #{blast_xml_output_file.path} " +
                      "-out #{blast2go_output_file.path} " +
                      "-prop #{blast2go_dir}/b2gPipe.properties -annot")
    #Raise an exception if there were errors with blast2go
    if not stderr.blank?
      raise StandardError, stderr
    end
    #Delete the temporary files
    File.delete(blast_xml_output_file.path)
    File.delete(blast2go_output_file.path)
    #Return the path of the resulting file containing the go terms
    return "#{blast2go_output_file.path}.annot"
  end
end
