#This is an abstract class
class AbstractQueryUsingBlast
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id, :text_area_fastas, :fasta_file, :num_alignments, 
                :evalue, :query_input_method, 
                :use_soft_masking, :filter_low_complexity_regions,
                :use_lowercase_masking
                
  attr_reader   :available_datasets, :available_num_alignments
  
  AVAILABLE_NUM_ALIGNMENTS = ['0','10','50','100','250','500']
  
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true
  validates :text_area_fastas, :presence => true,
                          :if => "@query_input_method == 'text_area'"
  validates :fasta_file, :uploaded_file => true
  validates :fasta_file, :presence => true, 
                   :if => "@query_input_method == 'file'"
  
  validates :num_alignments, :presence => true,
                             :inclusion => {:in => AVAILABLE_NUM_ALIGNMENTS}
  validates :evalue, :presence => true,
                      :numericality => true
  
  validates :query_input_method, :presence => true,
                                    :inclusion => {:in =>[
                                      'text_area',
                                      'file']
                                    }

  validates :use_soft_masking, :presence => true,
                                :view_model_boolean => true
  validates :use_lowercase_masking, :presence => true,
                                    :view_model_boolean => true
  validates :filter_low_complexity_regions, :presence => true,
                                            :view_model_boolean => true
  
  
  def initialize(current_user)
    #Set the current user
    @current_user = current_user
    #Set available datasets
    all_datasets_for_user = Dataset.find_all_by_user_id(@current_user)
    @available_datasets = all_datasets_for_user.map{|ds| [ds.name, ds.id]}
    #Set the available options for the number of alignments
    @available_num_alignments = AVAILABLE_NUM_ALIGNMENTS
  end
  
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    @dataset_id = @available_datasets.first[1] if @dataset_id.blank?
    @num_alignments = '100' if @num_alignments.blank?
    @evalue = 10.0 if @evalue.blank?
    @query_input_method = 'text_area' if @query_input_method.blank?
  end
  
  def blast()
    #Don't query if it is not valid
    return if not self.valid?
    #Record that the dataset was queried at this time
    ds = Dataset.find_by_id(@dataset_id)
    ds.when_last_queried = Time.now
    ds.save!
    prepare_IO_files()
    #Build the execution string
    blast_execution_string = generate_execution_string()
    #Execute blast
    SystemUtil.system!(blast_execution_string)
    #Run the blast query and get the file path of the result
    blast_report = generate_blast_report_from_xml_results()
    cleanup_files()
    return blast_report
  end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
    return false
  end
  
  protected
  
  def generate_execution_string
    #Filter by low complexity and soft masking map to soft masking due to
    #       http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
    #       and http://www.ncbi.nlm.nih.gov/BLAST/blastcgihelp.shtml#filter
    #If given a fasta sequence, write it to a temporary file so that it 
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  def prepare_IO_files()
    if @query_input_method == 'text_area'
      @query_input_file = Tempfile.new('query_using_blast')
      @query_input_file.write(@text_area_fastas)
    else
      @query_input_file = @fasta_file.tempfile
    end
    @query_input_file.close if not @query_input_file.closed?
    #Create a temporary file to store the blast output in xml format
    @xml_results_file = Tempfile.new('blast')
    @xml_results_file.close
  end
  
  def generate_blast_report_from_xml_results()
    #Parse the xml into Blast reports
    f = File.open(@xml_results_file.path)
    xml_string = ''
    while not f.eof?
      xml_string += f.readline
    end
    f.close()
    blast_report = Bio::Blast::Report.new(xml_string,'xmlparser')
    return blast_report
  end
  
  def cleanup_files()
    File.delete(@query_input_file.path)
    File.delete(@xml_results_file.path)
  end
end
