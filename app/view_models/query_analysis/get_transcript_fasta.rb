###
# View model for displaying the fasta sequence for a given transcript.
#
# <b>Associated Controller:</b> QueryAnalysisController
class GetTranscriptFasta
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'open3'
  
  # The id of the dataset containing the transcript_name
  attr_accessor :dataset_id 
  # The name of the transcript to find the fasta sequence for
  attr_accessor :transcript_name
  
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true
  validates :transcript_name, :presence => true
  
  def initialize(user)
    @current_user = user
  end
  
  # Set the view model's attributes
  def set_attributes(attributes = {})
    @dataset_id = attributes[:dataset_id]
    @transcript_name = attributes[:transcript_name]
  end
  
  # Return the transcripts fasta sequence by querying the dataset's blast 
  # database.
  def query
    #Get the transcript from the parameters
    raise(ActiveRecord::RecordInvalid,self) if not self.valid?
    dataset = Dataset.find_by_id(@dataset_id)
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
      # Return the transcript fasta sequence
      return stdout
  end
  
  # Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  # this defines that this model does not persist in the database.
  def persisted?
      return false
  end
end
 
