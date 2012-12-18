class Blastn_Query #< Blast_Query::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  #TODO: Describe meaning of these?
  attr_accessor :fasta_sequence, :num_alignments, :e_value,
                :word_size, :reward, :use_fasta_sequence_or_file,
                :penalty, :gap_open_penalty, :gap_extension_penalty,
                :use_soft_masking, :use_lowercase_masking, :gap_costs,
                :match_and_mismatch_scores
    
    attr_reader :available_datasets, :available_match_and_mismatch_scores,
                :available_gap_costs
    
    #For Boolean attributes, provide methods ending with a question mark 
    #  for convenience.
    def use_soft_masking?
      return @use_soft_masking
    end
    
    def use_lowercase_masking?
      return @use_lowercase_masking
    end
    
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
      'Linear' => :linear,
      'Existence: 5, Extension: 2' => {:existence => 5, :extention => 2},
      'Existence: 2, Extension: 2' => {:existence => 2, :extention => 2},
      'Existence: 1, Extension: 2' => {:existence => 1, :extention => 2},
      'Existence: 0, Extension: 2' => {:existence => 0, :extention => 2},
      'Existence: 3, Extension: 1' => {:existence => 3, :extention => 1},
      'Existence: 2, Extension: 1' => {:existence => 2, :extention => 1},
      'Existence: 1, Extension: 1' => {:existence => 1, :extention => 1},
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
      #Set available gap costs
      @available_gap_costs = AVAILABLE_GAP_COSTS.keys
    end
  
    def set_attributes_and_defaults(attributes = {})
      #Load in any values from the form
      attributes.each do |name, value|
          send("#{name}=", value)
      end
      #Set default values for Megablast, which is the only blastn program we will use
      #Defaults taken from http://www.ncbi.nlm.nih.gov/books/NBK1763/#CmdLineAppsManual.Appendix_C_Options_for
      # and http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
      @num_alignments = 250 if @num_alignments.blank?
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
    end
    
    def blast!()
      #Don't query if it is not valid
      return if not self.valid?
      #Filter by low complexity and soft masking map to soft masking due to
      #       http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
      #       and http://www.ncbi.nlm.nih.gov/BLAST/blastcgihelp.shtml#filter
      #Run Blastn
      #system('blastn ')
      #Format and add the graphical summary to the blast output
      #system('')
      
    end
    
    def persisted?
      return false
    end
    
    private
    def user_has_permission_to_access_dataset
    end
end