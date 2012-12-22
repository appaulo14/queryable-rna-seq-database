class TBlastn_Query #< Blast_Query::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  require 'tempfile'
  
  #TODO: Describe meaning of these?
  attr_accessor :dataset_id, :fasta_sequence, :fasta_file, :num_alignments, :e_value,
                :word_size, :use_fasta_sequence_or_file, :use_soft_masking, 
                :use_lowercase_masking, :gap_costs,
                :match_and_mismatch_scores, :compositional_adjustment
    
    attr_reader :available_datasets, :available_match_and_mismatch_scores,
                :available_gap_costs, :available_num_alignments,
                :available_compositional_adjustments
    
    #Declare Constants
    AVAILABLE_MATCH_AND_MISMATCH_SCORES = {
      '1,-2' => {:match => 1, :mismatch => -2},
      '1,-3' => {:match => 1, :mismatch => -3},
      '1,-4' => {:match => 1, :mismatch => -4},
      '2,-3' => {:match => 2, :mismatch => -3},
      '4,-5' => {:match => 4, :mismatch => -5},
      '1,-1' => {:match => 1, :mismatch => -1},
    }
    
    AVAILABLE_GAP_COSTS = {
      '1,-2' => {
        'Linear' => {:existence => 0, :extention => 0},
        'Existence: 5, Extension: 2' => {:existence => 5, :extention => 2},
        'Existence: 2, Extension: 2' => {:existence => 2, :extention => 2},
        'Existence: 1, Extension: 2' => {:existence => 1, :extention => 2},
        'Existence: 0, Extension: 2' => {:existence => 0, :extention => 2},
        'Existence: 3, Extension: 1' => {:existence => 3, :extention => 1},
        'Existence: 2, Extension: 1' => {:existence => 2, :extention => 1},
        'Existence: 1, Extension: 1' => {:existence => 1, :extention => 1}, 
      },
      '1,-3' => {
        'Linear' => {:existence => 0, :extention => 0},
        'Existence: 5, Extension: 2' => {:existence => 5, :extention => 2},
        'Existence: 2, Extension: 2' => {:existence => 2, :extention => 2},
        'Existence: 1, Extension: 2' => {:existence => 1, :extention => 2},
        'Existence: 0, Extension: 2' => {:existence => 0, :extention => 2},
        'Existence: 2, Extension: 1' => {:existence => 2, :extention => 1},
        'Existence: 1, Extension: 1' => {:existence => 1, :extention => 1},      
      },
      '1,-4' => {
        'Linear' => {:existence => 0, :extention => 0},
        'Existence: 5, Extension: 2' => {:existence => 5, :extention => 2},
        'Existence: 2, Extension: 2' => {:existence => 2, :extention => 2},
        'Existence: 1, Extension: 2' => {:existence => 1, :extention => 2},
        'Existence: 0, Extension: 2' => {:existence => 0, :extention => 2},
        'Existence: 2, Extension: 1' => {:existence => 2, :extention => 1},
        'Existence: 1, Extension: 1' => {:existence => 1, :extention => 1},      
      },
      '2,-3' => {
        'Linear' => {:existence => 0, :extention => 0},
        'Existence: 4, Extension: 4' => {:existence => 4, :extention => 4},
        'Existence: 2, Extension: 4' => {:existence => 2, :extention => 4}, 
        'Existence: 0, Extension: 4' => {:existence => 0, :extention => 4},
        'Existence: 3, Extension: 3' => {:existence => 3, :extention => 3},
        'Existence: 6, Extension: 2' => {:existence => 6, :extention => 2},
        'Existence: 5, Extension: 2' => {:existence => 5, :extention => 2},
        'Existence: 4, Extension: 2' => {:existence => 4, :extention => 2},
        'Existence: 2, Extension: 2' => {:existence => 2, :extention => 2},
      },
      '4,-5' => {
        'Linear' => {:existence => 0, :extention => 0},
        'Existence: 12, Extension: 8' => {:existence => 12, :extention => 8},
        'Existence: 6, Extension: 5' => {:existence => 6, :extention => 5},
        'Existence: 5, Extension: 5' => {:existence => 5, :extention => 5},
        'Existence: 4, Extension: 5' => {:existence => 4, :extention => 5},
        'Existence: 3, Extension: 5' => {:existence => 3, :extention => 5},
      },
      '1,-1' => {
        'Linear' => {:existence => 0, :extention => 0},
        'Existence: 5, Extension: 2' => {:existence => 5, :extention => 2},
        'Existence: 3, Extension: 2' => {:existence => 3, :extention => 2},
        'Existence: 2, Extension: 2' => {:existence => 2, :extention => 2},
        'Existence: 1, Extension: 2' => {:existence => 1, :extention => 2},
        'Existence: 0, Extension: 2' => {:existence => 0, :extention => 2},
        'Existence: 4, Extension: 1' => {:existence => 4, :extention => 1},
        'Existence: 3, Extension: 1' => {:existence => 3, :extention => 1},
        'Existence: 2, Extension: 1' => {:existence => 2, :extention => 1},
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
      #Set available match/mismatch scores
      @available_match_and_mismatch_scores = AVAILABLE_MATCH_AND_MISMATCH_SCORES.keys
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
      @word_size = 28 if @word_size.blank?
      @gap_open_penalty = 0 if @gap_open_penalty.blank?
      @gap_extension_penalty = nil
      @reward = 1 if @reward.blank?
      @penalty = -2 if @penalty.blank?
      @use_soft_masking = true if @use_soft_masking.blank?
      @use_lowercase_masking = false if @use_lowercase_masking.blank?
      if @use_fasta_sequence_or_file.blank?
        @use_fasta_sequence_or_file = :use_fasta_sequence
      end
      if @match_and_mismatch_scores.blank?
        @match_and_mismatch_scores = @available_match_and_mismatch_scores.first 
      end
      #Set available gap costs for the given match and mismatch scores
      @available_gap_costs = 
        AVAILABLE_GAP_COSTS[@match_and_mismatch_scores].keys
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
        query_input_file = Tempfile.new('blastn_query')
        query_input_file.write(@fasta_sequence)
        query_input_file.close
      else
        query_input_file = @fasta_file.tempfile
      end
      #Create a temporary file to store the blast output in xml format
      blast_xml_output_file = Tempfile.new('blastn')
      blast_xml_output_file.close
      #Create the blastn execution string that will be run on the command line,
      # including calculating all the options
      dataset = Dataset.find_by_id(@dataset_id)
      blastn_execution_string = "blastn -query #{query_input_file.path} " +
             "-db #{dataset.blast_db_location} " +
             "-out #{blast_xml_output_file.path} " +
             "-evalue #{@e_value} -word_size #{@word_size} " +
             "-num_alignments #{@num_alignments} " +
             "-show_gis -outfmt '5' "
      if @use_soft_masking == '0'
        blastn_execution_string += '-soft_masking false ' 
      else
        blastn_execution_string += '-soft_masking true '
      end
      if @use_lowercase_masking == '1'
        blastn_execution_string += '-lcase_masking '
      end
      gapopen = AVAILABLE_GAP_COSTS[@match_and_mismatch_scores][@gap_costs][:existence]
      gapextend = AVAILABLE_GAP_COSTS[@match_and_mismatch_scores][@gap_costs][:extention]
      blastn_execution_string += "-gapopen #{gapopen} -gapextend #{gapextend} "
      selected_match_and_mismatch_scores = 
        AVAILABLE_MATCH_AND_MISMATCH_SCORES[@match_and_mismatch_scores]
      match = selected_match_and_mismatch_scores[:match]
      mismatch = selected_match_and_mismatch_scores[:mismatch]
      blastn_execution_string += "-reward #{match} -penalty #{mismatch}"
      #TODO: Decide how to handle failures
      #Execute blastn
      system(blastn_execution_string)
      #Create a temporary file to store the final blast page, containing images and html
      blast_html_output_file = Tempfile.new('blastn')
      blast_html_output_file.close
      #Run a perl script to format and add the graphical summary to the blast output
      basename = File.basename(blast_html_output_file)
      system("perl lib/tasks/render_blast_output_with_graphics.pl " +
             "#{blast_xml_output_file.path} " +
             "#{blast_html_output_file.path} #{basename}")
      #Save the location of the blast output files so that the graphical 
      # summaries can be retrieved
      BlastGraphicalSummaryLocator.create!(
        :dataset => dataset, 
        :basename => basename, 
        :html_output_file_path => blast_html_output_file.path
      )
      #Return the result
      return blast_html_output_file.path
    end
    
    def persisted?
      return false
    end
    
    private
    def user_has_permission_to_access_dataset
    end
end