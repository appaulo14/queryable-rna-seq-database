require 'tempfile'
require 'query_analysis/abstract_query_using_blast.rb'

###
# View model for the query using Tblastn page.
#
# <b>Associated Controller:</b> QueryAnalysisController
#
# <b>Associated Worker:</b> WorkerForQueryUsingBlast
class QueryUsingTblastn < AbstractQueryUsingBlast
  # The gap costs
  attr_accessor :gap_costs
  # The matrix
  attr_accessor :matrix
  # The compositional adjustment
  attr_accessor :compositional_adjustment
  
  # The available valid options for the #matrix
  attr_reader :available_matrices
  # The available valid options for the gap_costs
  attr_reader :available_gap_costs
   # The available valid options for the compositional_adjustment
  attr_reader :available_compositional_adjustments                             
    
  # The available valid options for the word_size
  AVAILABLE_WORD_SIZES = ['2','3']
  
  # When a new #matrix is select, this determines what the 
  # default gap_costs will be for it
  AVAILABLE_GAP_COST_DEFAULTS = {
    'PAM30' => 'Existence: 9, Extension: 1',
    'PAM70' => 'Existence: 10, Extension: 1',
    'PAM250' =>  'Existence: 14, Extension: 2',
    'BLOSUM80' => 'Existence: 10, Extension: 1',
    'BLOSUM62' => 'Existence: 11, Extension: 1',
    'BLOSUM45' => 'Existence: 15, Extension: 2',
    'BLOSUM50' => 'Existence: 13, Extension: 2',
    'BLOSUM90' => 'Existence: 10, Extension: 1',
  }
    
  # The available valid options for the gap_costs
  AVAILABLE_GAP_COSTS = {
    'PAM30' => {
      'Existence: 7, Extension: 2' => {:existence => 7, :extention => 2},
      'Existence: 6, Extension: 2' => {:existence => 6, :extention => 2},
      'Existence: 5, Extension: 2' => {:existence => 5, :extention => 2},
      'Existence: 10, Extension: 1' => {:existence => 10, :extention => 1},
      'Existence: 9, Extension: 1' => {:existence => 9, :extention => 1},
      'Existence: 8, Extension: 1' => {:existence => 8, :extention => 1},
    },
    'PAM70' => {
      'Existence: 8, Extension: 2' => {:existence => 8, :extention => 2},
      'Existence: 7, Extension: 2' => {:existence => 7, :extention => 2},
      'Existence: 6, Extension: 2' => {:existence => 6, :extention => 2},
      'Existence: 11, Extension: 1' => {:existence => 11, :extention => 1},
      'Existence: 10, Extension: 1' => {:existence => 10, :extention => 1},
      'Existence: 9, Extension: 1' => {:existence => 9, :extention => 1},
    },
    'PAM250' => {
      'Existence: 15, Extension: 3' => {:existence => 15, :extention => 3},
      'Existence: 14, Extension: 3' => {:existence => 14, :extention => 3},   
      'Existence: 13, Extension: 3' => {:existence => 13, :extention => 3},   
      'Existence: 12, Extension: 3' => {:existence => 12, :extention => 3},   
      'Existence: 11, Extension: 3' => {:existence => 11, :extention => 3},   
      'Existence: 17, Extension: 2' => {:existence => 17, :extention => 2},   
      'Existence: 16, Extension: 2' => {:existence => 16, :extention => 2},   
      'Existence: 15, Extension: 2' => {:existence => 15, :extention => 2},   
      'Existence: 14, Extension: 2' => {:existence => 14, :extention => 2},   
      'Existence: 13, Extension: 2' => {:existence => 13, :extention => 2},   
      'Existence: 21, Extension: 1' => {:existence => 21, :extention => 1},   
      'Existence: 20, Extension: 1' => {:existence => 20, :extention => 1},   
      'Existence: 19, Extension: 1' => {:existence => 19, :extention => 1},   
      'Existence: 18, Extension: 1' => {:existence => 18, :extention => 1},   
      'Existence: 17, Extension: 1' => {:existence => 17, :extention => 1},   
    },
    'BLOSUM80' => {
      'Existence: 8, Extension: 2' => {:existence => 8, :extention => 2},
      'Existence: 7, Extension: 2' => {:existence => 7, :extention => 2},
      'Existence: 6, Extension: 2' => {:existence => 6, :extention => 2},
      'Existence: 11, Extension: 1' => {:existence => 11, :extention => 1},
      'Existence: 10, Extension: 1' => {:existence => 10, :extention => 1},
      'Existence: 9, Extension: 1' => {:existence => 9, :extention => 1},
    },
    'BLOSUM62' => {
      'Existence: 11, Extension: 2' => {:existence => 11, :extention => 2},
      'Existence: 10, Extension: 2' => {:existence => 10, :extention => 2},
      'Existence: 9, Extension: 2' => {:existence => 9, :extention => 2},
      'Existence: 8, Extension: 2' => {:existence => 8, :extention => 2},
      'Existence: 7, Extension: 2' => {:existence => 7, :extention => 2},
      'Existence: 6, Extension: 2' => {:existence => 6, :extention => 2},
      'Existence: 13, Extension: 1' => {:existence => 13, :extention => 1},
      'Existence: 12, Extension: 1' => {:existence => 12, :extention => 1},
      'Existence: 11, Extension: 1' => {:existence => 11, :extention => 1},
      'Existence: 10, Extension: 1' => {:existence => 10, :extention => 1},
      'Existence: 9, Extension: 1' => {:existence => 9, :extention => 1},
    },
    'BLOSUM45' => {
      'Existence: 13, Extension: 3' => {:existence => 13, :extention => 3},
      'Existence: 12, Extension: 3' => {:existence => 12, :extention => 3},
      'Existence: 11, Extension: 3' => {:existence => 11, :extention => 3},
      'Existence: 10, Extension: 3' => {:existence => 10, :extention => 3},
      'Existence: 15, Extension: 2' => {:existence => 15, :extention => 2},
      'Existence: 14, Extension: 2' => {:existence => 14, :extention => 2},
      'Existence: 13, Extension: 2' => {:existence => 13, :extention => 2},
      'Existence: 12, Extension: 2' => {:existence => 12, :extention => 2},
      'Existence: 19, Extension: 1' => {:existence => 19, :extention => 1},
      'Existence: 18, Extension: 1' => {:existence => 18, :extention => 1},
      'Existence: 17, Extension: 1' => {:existence => 17, :extention => 1},
      'Existence: 16, Extension: 1' => {:existence => 16, :extention => 1},
    },
    'BLOSUM50' =>{
      'Existence: 13, Extension: 3' => {:existence => 13, :extention => 3},
      'Existence: 12, Extension: 3' => {:existence => 12, :extention => 3},
      'Existence: 11, Extension: 3' => {:existence => 11, :extention => 3},
      'Existence: 10, Extension: 3' => {:existence => 10, :extention => 3},
      'Existence: 9, Extension: 3' => {:existence => 9, :extention => 3},
      'Existence: 16, Extension: 2' => {:existence => 16, :extention => 2},
      'Existence: 15, Extension: 2' => {:existence => 15, :extention => 2},
      'Existence: 14, Extension: 2' => {:existence => 14, :extention => 2},
      'Existence: 13, Extension: 2' => {:existence => 13, :extention => 2},
      'Existence: 12, Extension: 2' => {:existence => 12, :extention => 2},
      'Existence: 19, Extension: 1' => {:existence => 19, :extention => 1},
      'Existence: 18, Extension: 1' => {:existence => 18, :extention => 1},
      'Existence: 17, Extension: 1' => {:existence => 17, :extention => 1},
      'Existence: 16, Extension: 1' => {:existence => 16, :extention => 1},
      'Existence: 15, Extension: 1' => {:existence => 15, :extention => 1},
    },
    'BLOSUM90' =>{
      'Existence: 9, Extension: 2' => {:existence => 9, :extention => 2},
      'Existence: 8, Extension: 2' => {:existence => 8, :extention => 2},
      'Existence: 7, Extension: 2' => {:existence => 7, :extention => 2},
      'Existence: 6, Extension: 2' => {:existence => 6, :extention => 2},
      'Existence: 11, Extension: 1' => {:existence => 11, :extention => 1},
      'Existence: 10, Extension: 1' => {:existence => 10, :extention => 1},
      'Existence: 9, Extension: 1' => {:existence => 9, :extention => 1},
    },
  }
  
  # The available valid options for the #matrix
  AVAILABLE_MATRICES = ['PAM30','PAM70','PAM250','BLOSUM80',
                           'BLOSUM62','BLOSUM45','BLOSUM50','BLOSUM90']
  
  # The available valid options for the compositional_adjustment
  AVAILABLE_COMPOSITIONAL_ADJUSTMENTS = {
    'No adjustment' => '0',
    'Composition-based statistics' => '1',
    'Conditional compostional score matrix adjustment' => '2',
    'Universal compositional score matrix adjustment' => '3',
  }
                             
  #Validation
  validates :text_area_fastas, :protein_fasta_sequences => true
  validates :word_size, :presence => true,
                        :inclusion => {:in => AVAILABLE_WORD_SIZES}
  validates :gap_costs, :presence => true         
  validates :compositional_adjustment, :presence => true,
                :inclusion => {:in => AVAILABLE_COMPOSITIONAL_ADJUSTMENTS.values}
  validates :matrix, :presence => true,
                     :inclusion => {:in => AVAILABLE_MATRICES}
  validate :gap_costs_valid_for_selected_matrix
  
  ###
  # Returns the name of the blast program that this class provides.
  def self.get_program_name()
    return 'tblastn'
  end
  
  ###
  # parameters::
  # * <b>current_user:</b> The currently logged in user
  def initialize(current_user)
    super
    #Set the available options for the number of alignments
    @available_compositional_adjustments = AVAILABLE_COMPOSITIONAL_ADJUSTMENTS
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
    @compositional_adjustment = '2' if @compositional_adjustment.blank?
    @use_soft_masking = '0' if @use_soft_masking.blank?
    @use_lowercase_masking = '0' if @use_lowercase_masking.blank?
    if @filter_low_complexity_regions.blank?
      @filter_low_complexity_regions = '1'
    end
    if @matrix.blank?
      @matrix = 'BLOSUM62'
    end
    #Set available gap costs for the given matrix
    @available_gap_costs = AVAILABLE_GAP_COSTS[@matrix].keys
    if @gap_costs.blank?
      @gap_costs = AVAILABLE_GAP_COST_DEFAULTS[@matrix]
    end
  end
   
    
    private
    
    def generate_execution_string
      dataset = Dataset.find_by_id(@dataset_id)
      tblastn_execution_string = "bin/blast/bin/tblastn " +
             "-query #{@query_input_file.path} " +
             "-db #{dataset.blast_db_location} " +
             "-out #{@xml_results_file.path} " +
             "-evalue #{@evalue} -word_size #{@word_size} " +
             "-num_alignments #{@num_alignments} " +
             "-show_gis -outfmt '5' "
      if @use_soft_masking == '0'
        tblastn_execution_string += '-soft_masking false ' 
      else
        tblastn_execution_string += '-soft_masking true '
      end
      if @use_lowercase_masking == '1'
        tblastn_execution_string += '-lcase_masking '
      end
      if @filter_low_complexity_regions == '1'
        tblastn_execution_string += "-seg 'yes' "
      else
        tblastn_execution_string += "-seg 'no' "
      end
      gapopen = AVAILABLE_GAP_COSTS[@matrix][@gap_costs][:existence]
      gapextend = AVAILABLE_GAP_COSTS[@matrix][@gap_costs][:extention]
      tblastn_execution_string += "-gapopen #{gapopen} -gapextend #{gapextend} "
      tblastn_execution_string += "-matrix #{@matrix} "
      tblastn_execution_string += 
        "-comp_based_stats #{@compositional_adjustment} "
      return tblastn_execution_string
    end
    
    #### Validation methods ####
    def gap_costs_valid_for_selected_matrix()
      return if @gap_costs.blank? or @matrix.blank?
      if not AVAILABLE_MATRICES.include?(@matrix)
        return
      end
      if AVAILABLE_GAP_COSTS[@matrix][@gap_costs].nil?
        errors[:gap_costs] << 'must be one of the available gap costs ' +
          'for the selected matrix'
      end
    end
end
