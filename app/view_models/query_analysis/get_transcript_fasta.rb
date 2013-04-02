class GetTranscriptFasta
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'open3'
  
  attr_accessor :dataset_id, :transcript_name
  
  #TRANSCRIPT_NAME_REGEX = /\A(\w|\s|\.)+\z/
  
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true
  validates :transcript_name, :presence => true
  
  def initialize(user)
    @current_user = user
  end
  
  def set_attributes(attributes = {})
    @dataset_id = attributes[:dataset_id]
    @transcript_name = attributes[:transcript_name]
  end
  
  def query
    #Get the transcript from the parameters
    raise(ActiveRecord::RecordInvalid,self) if not self.valid?
    dataset = Dataset.find_by_id(@dataset_id)
#    transcript = Transcript.where(:dataset_id => @dataset_id, 
#                                  :name_from_program => @transcript_name)[0]
#    #Create the fasta string
#    if transcript.nil?
#      return 'No fasta sequences found.'
#    else
      #Create the fasta string for the transcript
      #TODO figure out how to handle failure
#      stdin, stdout, stderr = 
#        Open3.popen3('bin/blast/bin/blastdbcmd', 
#                     '-entry',"#{transcript.name_from_program}", 
#                     '-db',"#{transcript.dataset.blast_db_location}", 
#                     '-dbtype','nucl')
      stdout, stderr, status = 
        Open3.capture3('bin/blast/bin/blastdbcmd', 
                     '-entry',"#{@transcript_name}", 
                     '-db',"#{dataset.blast_db_location}", 
                     '-dbtype','nucl')
      if not stderr.blank?
        if stderr.match(/Entry not found in BLAST database/)
          return stderr
        else
          raise StandardError, stderr
        end
      end
     
        return stdout
#    end
  end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
end
 
