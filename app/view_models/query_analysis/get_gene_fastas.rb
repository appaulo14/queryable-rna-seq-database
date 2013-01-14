class Get_Gene_Fastas
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'open3'
  
  attr_accessor :dataset_id, :gene_name
  attr_reader :fastas_string
  
  GENE_NAME_REGEX = /\A(\w|\s|\.)+\z/
  
  validates :dataset_id, :presence => true,
                         :numericality => { :only_integer => true, 
                                            :greater_than => 0 }
  validates :gene_name, :presence => true,
                        :format => { :with => GENE_NAME_REGEX }   
  validate :user_has_permission_to_access_dataset
  
  def initialize(user)
    @current_user = user
  end
  
  def set_attributes(attributes = {})
    @dataset_id = attributes[:dataset_id]
    @gene_name = attributes[:gene_name]
  end
  
  def query!
    #Get the transcripts from the parameters
    raise(ActiveRecord::RecordInvalid,self) if not self.valid?
    gene = Gene.where(:dataset_id => @dataset_id, 
                      :name_from_program => @gene_name)[0]
    #Create the fasta string from the gene's transcripts
    @fastas_string = ''
    if gene.nil?
      @fastas_string = 'No fasta sequences found.'
    else
      seq_ids = []
      gene.transcripts.each do |t|
        seq_ids << t.blast_seq_id
      end
      stdin, stdout, stderr = 
        Open3.popen3('blastdbcmd', 
                     '-entry',"#{seq_ids.join(',')}", 
                     '-db',"#{gene.dataset.blast_db_location}", 
                     '-dbtype','nucl')
      @fastas_string = stdout.gets(nil)
    end
  end
  
  def persisted?
      return false
  end
  
  private
  def user_has_permission_to_access_dataset
  end
end
