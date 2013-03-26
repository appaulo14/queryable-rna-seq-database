require 'tempfile'

class QueryUsingBlastn
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  #TODO: Describe meaning of these?
  attr_accessor :dataset_id, :fasta_sequence, :fasta_file, :num_alignments, :e_value,
                :word_size, :use_fasta_sequence_or_file, :use_soft_masking, 
                :use_lowercase_masking, :gap_costs,
                :match_and_mismatch_scores, :filter_low_complexity_regions
    
  attr_reader :available_datasets, :available_word_sizes, 
              :available_match_and_mismatch_scores, :available_gap_costs,
              :available_num_alignments
                                  
    AVAILABLE_NUM_ALIGNMENTS = [0,10,50,"100",250,500]
    AVAILABLE_WORD_SIZES = [16,20,24,28,32,48,64,128,256]
    
    #Declare Constants
    AVAILABLE_MATCH_AND_MISMATCH_SCORES = {
      '1,-2' => {:match => 1, :mismatch => -2},
      '1,-3' => {:match => 1, :mismatch => -3},
      '1,-4' => {:match => 1, :mismatch => -4},
      '2,-3' => {:match => 2, :mismatch => -3},
      '4,-5' => {:match => 4, :mismatch => -5},
      '1,-1' => {:match => 1, :mismatch => -1},
    }
    
    AVAILABLE_GAP_COST_DEFAULTS = {
      '1,-2' => 'Linear',
      '1,-3' => 'Linear',
      '1,-4' => 'Linear',
      '2,-3' => 'Linear',
      '4,-5' => 'Linear',
      '1,-1' => 'Existence: 5, Extension: 2',
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
    
  #Validation
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true
  validates :fasta_sequence, :nucleotide_fasta_sequences => true
  validates :fasta_file, :uploaded_file => true
  validates :num_alignments, :presence => true,
                             :inclusion => {:in => AVAILABLE_NUM_ALIGNMENTS}
  validates :e_value, :presence => true,
                      :numericality => true
  validates :word_size, :presence => true,
                        :inclusion => {:in => AVAILABLE_WORD_SIZES}
  
  validates :use_fasta_sequence_or_file, :presence => true,
                                          :inclusion => {:in =>[
                                            'use_fasta_sequence',
                                            'use_fasta_file']
                                          }
  validate  :fasta_sequence_or_file_is_present_as_selected
  
  validates :use_soft_masking, :presence => true,
                                :view_model_boolean => true
  validates :use_lowercase_masking, :presence => true,
                                    :view_model_boolean => true
  validates :gap_costs, :presence => true
  validate  :gap_costs_valid_for_selected_match_and_mismatch_scores              
  validates :match_and_mismatch_scores, :presence => true,
                :inclusion => {:in => AVAILABLE_MATCH_AND_MISMATCH_SCORES.keys}
  validates :filter_low_complexity_regions, :presence => true,
                                            :view_model_boolean => true
    
    def initialize(current_user)
      #Set the current user
      @current_user = current_user
      #Set available datasets
      all_datasets_for_user = Dataset.find_all_by_user_id(@current_user)
      @available_datasets = all_datasets_for_user.map{|ds| [ds.name, ds.id]}
      #Set the available word sizes
      @available_word_sizes = AVAILABLE_WORD_SIZES
      #Set available match/mismatch scores
      @available_match_and_mismatch_scores = AVAILABLE_MATCH_AND_MISMATCH_SCORES.keys
      #Set the available options for the number of alignments
      @available_num_alignments = AVAILABLE_NUM_ALIGNMENTS
    end
  
    def set_attributes_and_defaults(attributes = {})
      #Load in any values from the form
      attributes.each do |name, value|
          send("#{name}=", value)
      end
      #Set default values for Megablast, which is the only blastn program we will use
      #Defaults taken from http://www.ncbi.nlm.nih.gov/books/NBK1763/#CmdLineAppsManual.Appendix_C_Options_for
      # and http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
      @dataset_id = @available_datasets.first[1] if @dataset_id.blank?
      @num_alignments = 100 if @num_alignments.blank?
      @e_value = 10.0 if @e_value.blank?
      @word_size = 28 if @word_size.blank?
      @use_soft_masking = '1' if @use_soft_masking.blank?
      @use_lowercase_masking = '0' if @use_lowercase_masking.blank?
      if @filter_low_complexity_regions.blank?
        @filter_low_complexity_regions = '1'
      end
      if @use_fasta_sequence_or_file.blank?
        @use_fasta_sequence_or_file = :use_fasta_sequence
      end
      if @match_and_mismatch_scores.blank?
        @match_and_mismatch_scores = @available_match_and_mismatch_scores.first 
      end
      #Set available gap costs for the given match and mismatch scores
      @available_gap_costs = 
        AVAILABLE_GAP_COSTS[@match_and_mismatch_scores].keys
      #Set default gap cost based on available gap costs
      if @gap_costs.blank? or not @available_gap_costs.include?(@gap_costs)
        @gap_costs = AVAILABLE_GAP_COST_DEFAULTS[@match_and_mismatch_scores]
      end
    end
    
    def blast()
      #Don't query if it is not valid
      return if not self.valid?
      #Build the execution string
      blastn_execution_string = generate_blastn_execution_string()
      #Execute blastn
      SystemUtil.system!(blastn_execution_string)
      File.delete(query_input_file.path)
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
    
    private
    
    def generate_blastn_execution_string
      #Filter by low complexity and soft masking map to soft masking due to
      #       http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
      #       and http://www.ncbi.nlm.nih.gov/BLAST/blastcgihelp.shtml#filter
      #If given a fasta sequence, write it to a temporary file so that it 
      # can be inputted into blastn
      if @use_fasta_sequence_or_file == 'use_fasta_sequence'
        @query_input_file = Tempfile.new('query_using_blastn')
        @query_input_file.write(@fasta_sequence)
        @query_input_file.close
      else
        @query_input_file = @fasta_file.tempfile
      end
      #Create a temporary file to store the blast output in xml format
      @xml_results_file = Tempfile.new('blastn')
      @xml_results_file.close
      #Create the blastn execution string that will be run on the command line,
      # including calculating all the options
      dataset = Dataset.find_by_id(@dataset_id)
      blastn_execution_string = "bin/blast/bin/blastn " +
             "-query #{@query_input_file.path} " +
             "-db #{dataset.blast_db_location} " +
             "-out #{@xml_results_file.path} " +
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
      if @filter_low_complexity_regions == '1'
        blastn_execution_string += "-dust 'yes' "
      else
        blastn_execution_string += "-dust 'no' "
      end
      gapopen = 
        AVAILABLE_GAP_COSTS[@match_and_mismatch_scores][@gap_costs][:existence]
      gapextend = 
        AVAILABLE_GAP_COSTS[@match_and_mismatch_scores][@gap_costs][:extention]
      blastn_execution_string += "-gapopen #{gapopen} -gapextend #{gapextend} "
      selected_match_and_mismatch_scores = 
        AVAILABLE_MATCH_AND_MISMATCH_SCORES[@match_and_mismatch_scores]
      match = selected_match_and_mismatch_scores[:match]
      mismatch = selected_match_and_mismatch_scores[:mismatch]
      blastn_execution_string += "-reward #{match} -penalty #{mismatch}"
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
      File.delete(xml_results_file_path)
      return blast_report
    end
    
    def cleanup_files()
      File.delete(@query_input_file.path)
      File.delete(@xml_results_file.path)
    end
    
    #### Validation methods ####
    def fasta_sequence_or_file_is_present_as_selected
      #TODO: Implement
    end
    
    def gap_costs_valid_for_selected_match_and_mismatch_scores
      #TODO: Implement
    end
end
