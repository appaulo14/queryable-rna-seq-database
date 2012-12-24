class Tblastn_Query #< Blast_Query::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'tempfile'
  
  #TODO: Describe meaning of these?
  attr_accessor :dataset_id, :fasta_sequence, :fasta_file, :num_alignments, :e_value,
                :word_size, :use_fasta_sequence_or_file, :use_soft_masking, 
                :use_lowercase_masking, :filter_low_complexity_regions,
                :gap_costs, :genetic_code,
                :matrix, :compositional_adjustment
    
    attr_reader :available_datasets, :available_matrices,
                :available_gap_costs, :available_num_alignments,
                :available_compositional_adjustments, 
                :available_genetic_codes
    
    #Declare Constants
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
    
    #TODO: Add validation 
    validate :user_has_permission_to_access_dataset
    
    def initialize(current_user)
      #Set the current user
      @current_user = current_user
      #Set available datasets
      all_datasets_for_user = Dataset.find_all_by_user_id(@current_user)
      @available_datasets = all_datasets_for_user.map{|ds| [ds.name, ds.id]}
      #Set the available options for the number of alignments
      @available_num_alignments = [0,10,50,100,250,500]
      @available_genetic_codes = [['Standard (1)',1],
                                  ['Vertebrate Mitochondrial (2)', 2],
                                  ['Yeast Mitochondrial (3)',3],
                                  ['Mold Mitochondrial (4)',4],
                                  ['Invertebrate Mitochondrial (5)',5],
                                  ['Ciliate Nuclear (6)',6],
                                  ['Echinoderm Mitochondrial (9)',9],
                                  ['Euplotid Nuclear (10)',10],
                                  ['Bacterial (11)',11],
                                  ['Alternative Yeast Nuclear (12)',12],
                                  ['Ascidian Mitochondrial (13)',13],
                                  ['Flatworm Mitochondrial (14)',14],
                                  ['Blepharisma Macronuclear (15)',15]]
      @available_compositional_adjustments = [
        ['No adjustment', 0],
        ['Composition-based statistics', 1],
        ['Conditional compostional score matrix adjustment', 2],
        ['Universal compositional score matrix adjustment', 3]
      ]
      @available_matrices = ['PAM30','PAM70','PAM250','BLOSUM80',
                             'BLOSUM62','BLOSUM45','BLOSUM90']
    end
  
    def set_attributes_and_defaults(attributes = {})
      #Load in any values from the form
      attributes.each do |name, value|
          send("#{name}=", value)
      end
      #Set default values for Megablast, which is the only blastn program we will use
      #Defaults taken from http://www.ncbi.nlm.nih.gov/books/NBK1763/#CmdLineAppsManual.Appendix_C_Options_for
      # and http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
      @dataset_id = @available_datasets.first[1]
      @num_alignments = 100 if @num_alignments.blank?
      @e_value = 10.0 if @e_value.blank?
      @word_size = 3 if @word_size.blank?
      @compositional_adjustment = 2
      @genetic_code = 1
      @use_soft_masking = false if @use_soft_masking.blank?
      @use_lowercase_masking = false if @use_lowercase_masking.blank?
      if @filter_low_complexity_regions.blank?
        @filter_low_complexity_regions = true
      end
      if @use_fasta_sequence_or_file.blank?
        @use_fasta_sequence_or_file = :use_fasta_sequence
      end
      if @matrix.blank?
        @matrix = 'BLOSUM62'
      end
      #Set available gap costs for the given matrix
      @available_gap_costs = AVAILABLE_GAP_COSTS[@matrix].keys
      if @gap_costs.blank? or not @available_gap_costs.include?(@gap_costs)
        @gap_costs = AVAILABLE_GAP_COST_DEFAULTS[@matrix]
      end
    end
    
    def blast!()
      #Don't query if it is not valid
      return if not self.valid?
      #Filter by low complexity and soft masking map to soft masking due to
      #       http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
      #       and http://www.ncbi.nlm.nih.gov/BLAST/blastcgihelp.shtml#filter
      #If given a fasta sequence, write it to a temporary file so that it 
      # can be inputted into blastn
      if @use_fasta_sequence_or_file == 'use_fasta_sequence'
        query_input_file = Tempfile.new('tblastn_query')
        query_input_file.write(@fasta_sequence)
        query_input_file.close
      else
        query_input_file = @fasta_file.tempfile
      end
      #Create a temporary file to store the blast output in xml format
      blast_xml_output_file = Tempfile.new('tblastn')
      blast_xml_output_file.close
      #Create the blastn execution string that will be run on the command line,
      # including calculating all the options
      dataset = Dataset.find_by_id(@dataset_id)
      tblastn_execution_string = "bin/blast/bin/tblastn " +
             "-query #{query_input_file.path} " +
             "-db #{dataset.blast_db_location} " +
             "-out #{blast_xml_output_file.path} " +
             "-evalue #{@e_value} -word_size #{@word_size} " +
             "-num_alignments #{@num_alignments} " +
             "-show_gis -html "#-outfmt '5' "
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
      tblastn_execution_string += "-db_gencode #{@genetic_code}"
      #TODO: Decide how to handle failures
      #Execute blastn
      system(tblastn_execution_string)
      return blast_xml_output_file.path
#       #Create a temporary file to store the final blast page, containing images and html
#       blast_html_output_file = Tempfile.new('tblastn')
#       blast_html_output_file.close
#       #Run a perl script to format and add the graphical summary to the blast output
#       basename = File.basename(blast_html_output_file)
#       system("perl bin/render_blast_output_with_graphics.pl " +
#              "#{blast_xml_output_file.path} " +
#              "#{blast_html_output_file.path} #{basename}")
#       #Save the location of the blast output files so that the graphical 
#       # summaries can be retrieved
#       BlastGraphicalSummaryLocator.create!(
#         :dataset => dataset, 
#         :basename => basename, 
#         :html_output_file_path => blast_html_output_file.path
#       )
#       #Return the result
#       return blast_html_output_file.path
    end
    
    def persisted?
      return false
    end
    
    private
    def user_has_permission_to_access_dataset
    end
end