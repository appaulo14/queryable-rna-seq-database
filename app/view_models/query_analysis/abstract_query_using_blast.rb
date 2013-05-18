###
# Abstract view model for the view models of all of the blast pages.
#
# <b>Associated Controller:</b> QueryAnalysisController
class AbstractQueryUsingBlast
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  # The id of the dataset whose blast database will be queried
  attr_accessor :dataset_id
  # The fasta sequences that will be queried if query_input_method is 'text_area'
  attr_accessor :text_area_fastas
  # The file containing the fasta sequences that will be queried if 
  # query_input_method is 'file'
  attr_accessor :fasta_file
  # The number of alignments to show for the blast query
  attr_accessor :num_alignments
  # The e-value
  attr_accessor :evalue
  # Whether to get the query sequences from the html text area or an uploaded file
  attr_accessor :query_input_method 
  # Whether to use the soft masking blast option
  attr_accessor :use_soft_masking
  # Whether to filter by low complexity regions
  attr_accessor :filter_low_complexity_regions
  # Whether to use lowercase masking
  attr_accessor :use_lowercase_masking
  attr_accessor :results_display_method
  
  # The datasets that are available to the user for having their blast 
  # databases blasted
  attr_reader   :available_datasets
  # The available valid options for the num_alignments attribute
  attr_reader   :available_num_alignments
  
  # The available valid options for the num_alignments attribute
  AVAILABLE_NUM_ALIGNMENTS = ['10','50','100','250','500','1000','5000','10000','20000']
  
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
  validates :results_display_method, :presence => true,
                                     :inclusion => {:in => ['normal','email']}
  
  def self.get_program_name()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  ###
  # parameters::
  # * <b>current_user:</b> The currently logged in user
  def initialize(current_user)
    #Set the current user
    @current_user = current_user
    #Set available datasets
    all_datasets_for_user = Dataset.where(:user_id => @current_user.id,
                                          :finished_uploading => true)
                                   .order(:name)
    @available_datasets = all_datasets_for_user.map{|ds| [ds.name, ds.id]}
    #Set the available options for the number of alignments
    @available_num_alignments = AVAILABLE_NUM_ALIGNMENTS
  end
  
  # Set the view model's attributes or set those attributes to their 
  # default values
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    @dataset_id = @available_datasets.first[1] if @dataset_id.blank?
    @num_alignments = '100' if @num_alignments.blank?
    @evalue = 10.0 if @evalue.blank?
    @query_input_method = 'text_area' if @query_input_method.blank?
    @results_display_method = 'normal' if @results_display_method.blank?
  end
  
  # Blast the dataset's blast database and return the results as a 
  # Bio::Blast::Report[http://bioruby.org/rdoc/Bio/Blast/Report.html] object.
  def blast()
    #Don't query if it is not valid
    return if not self.valid?
    begin 
      #Record that the dataset was queried at this time
      dataset = Dataset.find_by_id(@dataset_id)
      dataset.when_last_queried = Time.now
      dataset.save!
      prepare_IO_files()
      #Build the execution string
      blast_execution_string = generate_execution_string()
      #Execute blast
      SystemUtil.system!(blast_execution_string)
      #Run the blast query and get the file path of the result
      blast_report = generate_blast_report_from_xml_results()
      cleanup_files()
      if @results_display_method == 'email'
        QueryAnalysisMailer.send_blast_report(self,blast_report,@current_user)
      else
        return blast_report
      end
    rescue Exception => ex
      begin
        QueryAnalysisMailer.send_blast_failure_message(self,@current_user)
      rescue Exception => ex2
        Rails.logger.error "For dataset #{dataset.id} with name #{dataset.name}:\n" +
                          "#{ex2.message}\n#{ex2.backtrace.join("\n")}"
        raise ex2, ex2.message
      ensure
        #Log the exception manually because Rails doesn't want to in this case
        Rails.logger.error "For dataset #{dataset.id} with name #{dataset.name}:\n" +
                          "#{ex.message}\n#{ex.backtrace.join("\n")}"
      end
    end
  end
  
  # Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  # this defines that this model does not persist in the database.
  def persisted?
    return false
  end
  
  protected
  
  # This is an abstract method that must be implemented in the subclass. 
  # It generates the execution string used to do the blasting.
  def generate_execution_string
    #Filter by low complexity and soft masking map to soft masking due to
    # http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
    # and http://www.ncbi.nlm.nih.gov/BLAST/blastcgihelp.shtml#filter
    #If given a fasta sequence, write it to a temporary file so that it 
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  # Create some temporary files to use for blast querying
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
  
  # Read the xml results file from the blast, turn it into a 
  # Bio::Blast::Report[http://bioruby.org/rdoc/Bio/Blast/Report.html] object, 
  # and return it
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
  
  # Delete the temporary files generated during the blast query
  def cleanup_files()
    File.delete(@query_input_file.path)
    File.delete(@xml_results_file.path)
  end
end
