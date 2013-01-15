class Get_Transcript_Fasta
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'open3'
  
  attr_accessor :dataset_id, :transcript_name
  attr_reader :fasta_string
  
  TRANSCRIPT_NAME_REGEX = /\A(\w|\s|\.)+\z/
  
  validates :dataset_id, :presence => true,
                         :numericality => { :only_integer => true, 
                                            :greater_than => 0 }
  validates :transcript_name, :presence => true,
                        :format => { :with => TRANSCRIPT_NAME_REGEX }   
  validate :user_has_permission_to_access_dataset
  
  def initialize(user)
    @current_user = user
  end
  
  def set_attributes(attributes = {})
    @dataset_id = attributes[:dataset_id]
    @transcript_name = attributes[:transcript_name]
  end
  
  def query!
    #Get the transcript from the parameters
    raise(ActiveRecord::RecordInvalid,self) if not self.valid?
    transcript = Transcript.where(:dataset_id => @dataset_id, 
                                  :name_from_program => @transcript_name)[0]
    #Create the fasta string
    if transcript.nil?
      @fasta_string = 'No fasta sequences found.'
    else
      #Create the fasta string for the transcript
      #TODO figure out how to handle failure
      stdin, stdout, stderr = 
        Open3.popen3('bin/blast/bin/blastdbcmd', 
                     '-entry',"#{transcript.blast_seq_id}", 
                     '-db',"#{transcript.dataset.blast_db_location}", 
                     '-dbtype','nucl')
      @fasta_string = stdout.gets(nil)
#       system("blastdbcmd -entry #{transcript.blast_seq_id}" +
#              "-db #{transcript.dataset.blast_db_location} -dbtype nucl")
#       @fasta_string = ">#{transcript.fasta_description}\n" +
#                       "#{transcript.fasta_sequence}\n"
    end
  end
  
  def persisted?
      return false
  end
  
  private
  def user_has_permission_to_access_dataset
  end
end
 
