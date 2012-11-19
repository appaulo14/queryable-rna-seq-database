class Upload_EdgeR
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :trinity_fasta_file, 
                :gene_differential_expression_file, 
                :transcript_differential_expression_file, 
                :gene_fpkm_file, 
                :transcript_fpkm_file
  
  validate :validate_trinity_fasta_file, :presence => true
  validate :validate_differential_expression_file, :presence => true
  
  def initialize(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
  end
  
  def save!
    debugger if ENV['RAILS_DEBUG'] == 'true'
    puts "hello world"
    x = 1
    #Create new job
    job = Job.new
    job.output_from_prorgam = "trinity_with_edger"
    #Read the normalized genes FPKM file, writing to genes and fpkm_samples
    header_line = gene_fpkm_file.tempfile.readline
    samples_names = header_line.split("\t")
    while not transcript_fpkm_file.tempfile.eof?
      table_cells = gene_fpkm_file.tempfile.readline.split("\t")
      gene_name = table_cells.shift
      sample_fpkms = table_cells
      gene = Gene.new(:job => job, 
                      :name_from_program => gene_name)
      gene.save!
      if sample_names.length == sample_fpkms.length
        (0..sample_fpkms.length).each do |i|
          fpkm_sample = FpkmSample.new(:gene => gene,
                                       :sample_name => sample_names[i],
                                       :q_fpkm => sample_fpkms[i])
          fpkm_sample.save!
        end
      end
    end
    #Read the normalized transcripts FPKM file, connecting transcripts to genes
    #   and writing transcripts and fpkm_samples
    header_line = transcript_fpkm_file.tempfile.readline
    samples_names = header_line.split("\t")
    while not transcript_fpkm_file.tempfile.eof?
      table_cells = transcript_fpkm_file.tempfile.readline.split("\t")
      transcript_name = table_cells.shift
      sample_fpkms = table_cells
      associated_gene = 
          Gene.find_by_name_from_program(transcript_name.gsub(/_seq\d+/,""))
      transcript = Transcript.new(:job => job, 
                                  :name_from_program => transcript_name,
                                  :gene => associated_gene)
      transcript.save!
      if (sample_names.length == sample_fpkms.length)
        (0..sample_fpkms.length).each do |i|
          fpkm_sample = FpkmSample.new(:transcript => transcript,
                                       :sample_name => sample_names[i],
                                       :q_fpkm => sample_fpkms[i])
          fpkm_sample.save!
        end
      end
    end
    #Read the differential expression file for transcripts, writing the differential expression table
    #Read the differential expression file for genes, writing the differential expression table
    #Read the Trinity.fasta file, writing to the transcript table
    #Run blast2go, writing to the genes table
    #Write Trinity.fasta to database
#     line = trinity_fasta_file.readline
#     while not trinity_fasta_file.tempfile.eof?
#       #If this is a fasta description line
#       if line.match(/\A>/)
#         transcript = Transcript.new(:job => job)
#         #transcript.name_from_program = 
#         #transcript.fasta_description = 
#         while not line.match(/\A>/)
#           fasta_sequence+=line
#         end
#         transcript.fasta_sequence = sequence
#       end
#     end
    #Write differential expression tests?
    #Delete the files
  end
  
  def persisted?
      return false
  end
  
  private
  def validate_trinity_fasta_file
    
  end
  
  def validate_transcript_differential_expression_file
    #Ensure this is a file before parsing it
#     return if trinity_fasta_file.nil?
#     if not trinity_fasta_file.kind_of? ActionDispatch::Http::UploadedFile
#       errors[:trinity_fasta_file] << "Must be a file."
#       return
#     end
#     
#     #loop through the file.
#     debugger if ENV['RAILS_DEBUG'] == 'true'
#     trinity_fasta_file.tempfile
    #Must have 7 columns
    #Last 4 columns must be convertable to double types
  end
  
  def validate_gene_differential_expression_file
  end
  
  def validate_transcript_fpkm_file
    #Confirm at least two samples in header column
    #Confirm all rows have the right number of fpkm_samples
  end
  
  def validate_gene_fpkm_file
  end
end
