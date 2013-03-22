class GoTermFinderAndProcessor
  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end
  
  def find_go_terms()
    #Run blastx
    @blast_xml_output_file = Tempfile.new('blastx')
    @blast_xml_output_file.close
    stdout, stderr, status = 
      Open3.capture3("#{Rails.root}/bin/blast/bin/blastx " +
                    "-remote -db nr " +
                    "-query #{@uploaded_file.tempfile.path} " +
                    "-out #{@blast_xml_output_file.path} " +
                    "-show_gis -outfmt '5' ")
    #Raise an exception if there were errors with blastx
    if not stderr.blank?
      raise StandardError, stderr
    end
  end
  
  def process_go_terms()
    blast2go_output_file = Tempfile.new('blast2go')
    blast2go_output_file.close
    blast2go_dir = "#{Rails.root}/bin/blast2go"
    stdout, stderr, status = 
      Open3.capture3("java -Xmx4000m " +
                      "-cp *:#{blast2go_dir}/ext/*:#{blast2go_dir}/* " +
                      "es.blast2go.prog.B2GAnnotPipe " +
                      "-in #{@blast_xml_output_file.path} " +
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
