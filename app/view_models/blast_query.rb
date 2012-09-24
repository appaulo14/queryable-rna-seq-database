class Blast_Query
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    
    attr_accessor :program, :database, :fasta_sequence,:fasta_file,
        :subsequence_from,:subsequence_to,:filter_for_low_complexity,:mask_for_lookup_table_only,
        :e_value,:matrix,:perform_ungapped_alignment,:query_genetic_codes,:database_genetic_codes,:frame_shift_penalty,
        :gap_open_penalty,:gap_extension_penalty,:mismatch_penalty,:match_reward,
        :blastn_word_size,:non_blastn_word_size,:number_of_one_line_descriptions,
        :number_of_alignments_to_show,:ouput_format
    
    validate :validate_fasta
    
    def initialize(attributes = {})
        attributes.each do |name, value|
            send("#{name}=", value)
        end
    end
    
    def persisted?
        return false
    end
    
    private
    
    #Try BioRuby's seq.illegal_bases.nil? to validate fasta
    def validate_fasta
        if (self.fasta_sequence.empty? and self.fasta_file.nil?)
            errors[:fasta_sequence] << "Please enter a fasta sequence and/or upload a fasta file"
            errors[:fasta_file] << "Please enter a fasta sequence and/or upload a fasta file"
        elsif (not self.fasta_sequence.empty?)
            #Parse fasta sequence to validate it
            tmp_sequence = self.fasta_sequence
            tmp_sequence.gsub!(/^([>].+)$/,'');    #remove description lines
            tmp_sequence.gsub!(/\n/,'');
            if (tmp_sequence.empty?)
                errors[:fasta_sequence] << "Please enter some sequence letters, not just comments."
            end
        elsif (not self.fasta_file.nil?)
        end
    end
 
    #validates_presence_of :name
    #validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
    #validates_length_of :content, :maximum => 500
end 
