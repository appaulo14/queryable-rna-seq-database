require 'tempfile'
require 'query_analysis/abstract_query_using_blast.rb'

###
# View model for the query using Tblastx page.
#
# <b>Associated Controller:</b> QueryAnalysisController
#
# <b>Associated Worker:</b> WorkerForQueryUsingBlast
class QueryUsingTblastx < AbstractQueryUsingBlast
  # The genetic code
  attr_accessor  :genetic_code
  # The matrix 
  attr_accessor  :matrix
  
  # The available valid options for the #matrix
  attr_reader    :available_matrices
  # The available valid options for the genetic_code
  attr_reader    :available_genetic_codes
  
  # The available valid options for the word_size
  AVAILABLE_WORD_SIZES = ['2','3']
  
  # The available valid options for the genetic_code
  AVAILABLE_GENETIC_CODES = {
    'Standard (1)' => '1',
    'Vertebrate Mitochondrial (2)' => '2',
    'Yeast Mitochondrial (3)' => '3',
    'Mold Mitochondrial (4)' => '4',
    'Invertebrate Mitochondrial (5)' => '5',
    'Ciliate Nuclear (6)' => '6',
    'Echinoderm Mitochondrial (9)' => '9',
    'Euplotid Nuclear (10)' => '10',
    'Bacterial (11)' => '11',
    'Alternative Yeast Nuclear (12)' => '12',
    'Ascidian Mitochondrial (13)' => '13',
    'Flatworm Mitochondrial (14)' => '14',
    'Blepharisma Macronuclear (15)' => '15'
  }
  
  # The available valid options for the #matrix
  AVAILABLE_MATRICES = ['PAM30','PAM70','PAM250','BLOSUM80',
                             'BLOSUM62','BLOSUM45','BLOSUM90']
    
  #Validation
  validates :text_area_fastas, :nucleotide_fasta_sequences => true
  validates :word_size, :presence => true,
                        :inclusion => {:in => AVAILABLE_WORD_SIZES}
  validates :genetic_code, :presence => true,
                           :inclusion => {:in => AVAILABLE_GENETIC_CODES.values}
  validates :matrix, :presence => true,
                     :inclusion => {:in => AVAILABLE_MATRICES}
  
  ###
  # Returns the name of the blast program that this class provides.
  def self.get_program_name()
    return 'tblastx'
  end
  
  ###
  # parameters::
  # * <b>current_user:</b> The currently logged in user
  def initialize(current_user)
    super
    #Set the available options for the number of alignments
    @available_genetic_codes = AVAILABLE_GENETIC_CODES
    @available_matrices = AVAILABLE_MATRICES
    @available_word_sizes = AVAILABLE_WORD_SIZES
  end
  
    # Set the view model's attributes or set those attributes to their 
    # default values
    def set_attributes_and_defaults(attributes = {})
      super
      #Set default values for Megablast, which is the only blastn program we will use
      #Defaults taken from http://www.ncbi.nlm.nih.gov/books/NBK1763/#CmdLineAppsManual.Appendix_C_Options_for
      # and http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
      @word_size = '3' if @word_size.blank?
      @use_soft_masking = '0' if @use_soft_masking.blank?
      @use_lowercase_masking = '0' if @use_lowercase_masking.blank?
      if @filter_low_complexity_regions.blank?
        @filter_low_complexity_regions = '1'
      end
      @matrix = 'BLOSUM62' if @matrix.blank?
      @genetic_code = '1' if @genetic_code.blank?
    end
    
    private
    
    def generate_execution_string
      dataset = Dataset.find_by_id(@dataset_id)
      tblastx_execution_string = 
        "bin/blast/bin/tblastx " +
        "-query #{@query_input_file.path} " +
        "-db #{dataset.blast_db_location} " +
        "-out #{@xml_results_file.path} " +
        "-evalue #{@evalue} -word_size #{@word_size} " +
        "-num_alignments #{@num_alignments} " +
        "-show_gis -outfmt '5' "
      if @use_soft_masking == '0'
        tblastx_execution_string += '-soft_masking false ' 
      else
        tblastx_execution_string += '-soft_masking true '
      end
      if @use_lowercase_masking == '1'
        tblastx_execution_string += '-lcase_masking '
      end
      if @filter_low_complexity_regions == '1'
        tblastx_execution_string += "-seg 'yes' "
      else
        tblastx_execution_string += "-seg 'no' "
      end
      tblastx_execution_string += "-matrix #{@matrix} "
      tblastx_execution_string += "-query_gencode #{@genetic_code} "
    end   
end
