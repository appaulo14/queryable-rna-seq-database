class Upload_EdgeR
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :trinity_fasta_file, :differential_expression_file
  
  validate :validate_trinity_fasta_file, :presence => true
  validate :validate_differential_expression_file, :presence => true
  
  def initialize(attributes = {})
  end
  
  def save!
    debugger if ENV['RAILS_DEBUG'] == 'true'
    puts "hello world"
    x = 1
    #Write Trinity.fasta?
    #Write differential expression tests?
  end
  
  def persisted?
      return false
  end
  
  private
  def validate_trinity_fasta_file
    
  end
  
  def validate_differential_expression_file
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
end
