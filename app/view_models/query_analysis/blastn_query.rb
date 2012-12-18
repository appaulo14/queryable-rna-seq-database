class Blastn_Query #< Blast_Query::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  #TODO: Describe meaning of these?
  attr_accessor :fasta_sequence, :num_alignments, :e_value,
                :word_size, :reward, :use_fasta_sequence_or_file,
                :penalty, :gap_open_penalty, :gap_extension_penalty,
                :use_soft_masking, :use_lowercase_masking
    
    attr_reader :available_databases
    
    #For Boolean attributes, provide methods ending with a question mark 
    #  for convenience.
    def use_soft_masking?
      return @use_soft_masking
    end
    
    def use_lowercase_masking?
      return @use_lowercase_masking
    end
    
    #TODO: Add validation 
    validate :user_has_permission_to_access_dataset
    
    def initialize(user)
      @current_user = user
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
    
    def query()
        #Filter by low complexity and soft masking map to soft masking due to
        #       http://www.ncbi.nlm.nih.gov/books/NBK1763/table/CmdLineAppsManual.T.blastn_application_o/?report=objectonly
        #       and http://www.ncbi.nlm.nih.gov/BLAST/blastcgihelp.shtml#filter
    end
    
    def persisted?
      return false
    end
    
    private
    def user_has_permission_to_access_dataset
    end
end