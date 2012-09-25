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
    
    validates :subsequence_from, :numericality => { :greater_than => 0.0 }#, :less_than_or_equal_to => :subsequence_to }
    #validates :subsequence_to, :numericality => { :greater_than => 0.0 }
    
    def initialize(attributes = {})
        attributes.each do |name, value|
            send("#{name}=", value)
        end
        if (self.program.nil?)
            self.program=:blastn
        end
        if (self.subsequence_from.nil?)
            self.subsequence_from = 1
        end
        if (self.fasta_sequence.nil?)
            self.fasta_sequence = ""
        end
    end
    
    def persisted?
        return false
    end
    
    private
    
    #Try BioRuby's seq.illegal_bases.nil? to validate fasta
    #FASTA format specification
    def validate_fasta       
        #Validate the fasta sequence if there is something in it
        self.fasta_sequence.strip! #remove white space and tabs from the ends
        if (not self.fasta_sequence.empty?)
            #Parse fasta sequence to validate it
            tmp_sequence = self.fasta_sequence
            tmp_sequence.gsub!(/^([>].+)$/,'')    #remove description lines
            tmp_sequence.gsub!(/\n|\r/,'') #remove the newlines
            #Validate that the sequence contains data besides description lines
            if (tmp_sequence.empty?)
                errors[:fasta_sequence] << "Please enter some sequence letters, not just fasta definition lines"
                return
            end
            #Validate that sequence is a protein sequence if that is what
            #   the blast program expects
            if (self.program == :blastp or self.program == :tblastn)
                if ( not (tmp_sequence =~/\A[ABCDEFGHIKLMNPQRSTUVWYZX*\-]+\z/i))
                    illegal_characters = tmp_sequence.scan(/([^ABCDEFGHIKLMNPQRSTUVWYZX*\-])/i).uniq.flatten
                    illegal_characters_string=""
                    illegal_characters.each do |i|
                        illegal_characters_string+=i
                    end
                    errors[:fasta_sequence] << "Your fasta sequence seems to " +
                        "have the following invalid characters in it: " +
                        "#{illegal_characters_string}. Please see the fasta format" +
                        "specification."
                end
            #Validate that the sequence is a nucleotide sequence if that is what
            #   the blast program expects
            else
                if ( not (tmp_sequence =~/\A[ATGCX\-]+\z/i))
                    illegal_characters = tmp_sequence.scan(/([^ATGCX\-])/i).uniq.flatten
                    illegal_characters_string=""
                    illegal_characters.each do |i|
                        illegal_characters_string+=i
                    end
                    errors[:fasta_sequence] << "Your fasta sequence seems to " +
                        "have the following invalid characters in it: " +
                        "#{illegal_characters_string}. If you want to do a " +
                        "protein query, please select the blastp or tblastn program. " +
                        "Otherwise, see the fasta format specification."
                end
            end
            #Validate that the subsequence range is within the range of the actual sequence
            if tmp_sequence.length <self.subsequence_to.to_i
                errors[:subsequence] << "The subsequence upper bound cannot be greater " +
                    "than the length of the fasta sequence (" + tmp_sequence.length.to_s + ")"
            end
        #Validat the uploaded fasta file if one was uploaded
        elsif (not self.fasta_file.nil?)
        else
            errors[:fasta_sequence] << "Please enter a fasta sequence and/or upload a fasta file"
            errors[:fasta_file] << "Please enter a fasta sequence and/or upload a fasta file"
        end
    end
end 
