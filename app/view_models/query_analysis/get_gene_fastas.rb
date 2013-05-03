###
# View model for displaying the fasta sequences associated with a given gene.
#
# <b>Associated Controller:</b> QueryAnalysisController
class GetGeneFastas
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'open3'
  
  # The id of the dataset containing the gene_name
  attr_accessor :dataset_id
  # The name of the gene whose transcripts the fasta sequences will be found for
  attr_accessor :gene_name
  
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true
  validates :gene_name, :presence => true 
  
  def initialize(current_user)
    @current_user = current_user
  end
  
  # Set the view model's attributes
  def set_attributes(attributes = {})
    @dataset_id = attributes[:dataset_id]
    @gene_name = attributes[:gene_name]
  end
  
  # Return the fasta sequences for the transcripts associated with the gene
  # by querying the dataset's blast database.
  def query
    #Get the transcripts from the parameters
    raise(ActiveRecord::RecordInvalid,self) if not self.valid?
    gene = Gene.where(:dataset_id => @dataset_id, 
                      :name_from_program => @gene_name)[0]
    #Create the fasta string from the gene's transcripts
    if gene.nil?
      return 'No fasta sequences found.'
    else
      seq_ids = []
      gene.transcripts.each do |t|
        seq_ids << t.name_from_program
      end
      stdin, stdout, stderr = 
        Open3.popen3('bin/blast/bin/blastdbcmd', 
                     '-entry',"#{seq_ids.join(',')}", 
                     '-db',"#{gene.dataset.blast_db_location}", 
                     '-dbtype','nucl')
      return stdout.gets(nil)
    end
  end
  
  # According to http://railscasts.com/episodes/219-active-model?view=asciicast,
  # this defines that this view model does not persist in the database.
  def persisted?
      return false
  end
end
