class Blast_Query
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    
    attr_accessor :program, :dataset, :fasta_sequence,:fasta_file, #:subsequence_from,:subsequence_to,
        :filter_for_low_complexity,:mask_for_lookup_table_only, :e_value,:matrix,#:perform_ungapped_alignment,
        :query_genetic_codes,:database_genetic_codes,:frame_shift_penalty,
        :gap_open_penalty,:gap_extension_penalty,:mismatch_penalty,:match_reward,
        :blastn_word_size,:non_blastn_word_size,:number_of_one_line_descriptions,
        :number_of_alignments_to_show,:ouput_format
    
    #TODO: Add database validation
    validate :validate_fasta_and_subsequences
    validates :filter_for_low_complexity, :inclusion => {:in => [true, false]}
    validates :mask_for_lookup_table_only, :inclusion => {:in => [true, false]}
    
    #validates :subsequence_from, :numericality => { :greater_than => 0.0 }#, :less_than_or_equal_to => :subsequence_to }
    #validates :subsequence_to, :numericality => { :greater_than => 0.0 }
    
    def initialize(attributes = {})
        QueryAnalysisHelper.goat()
        #Load in any values from the form
        attributes.each do |name, value|
            send("#{name}=", value)
        end
        #Set the default values if they were not filled in by form data
        if (self.program.nil?)
            self.program=:blastn
        end
        if (self.fasta_sequence.nil?)
            self.fasta_sequence = ""
        end
#         if (self.subsequence_from.nil? or self.subsequence_from.empty?)
#             self.subsequence_from = 1
#         end
        if (self.filter_for_low_complexity.nil?)
            self.filter_for_low_complexity = true
        end
        if (self.mask_for_lookup_table_only.nil?)
            self.mask_for_lookup_table_only = true
        end
    end
    
    def persisted?
        return false
    end
    
    private
    
    def validate_fasta_and_subsequences
        validate_subsequences()
        #Validate the fasta sequence if there is something in it
        self.fasta_sequence.strip! #remove white space and tabs from the ends
        if (not self.fasta_sequence.empty?)
            validate_fasta_sequence()
        #Validate the uploaded fasta file if one was uploaded
        elsif (not self.fasta_file.nil?)
            validate_fasta_file()
        #If neither a file was uploaded nor a fasta sequence entered,create errors messages    
        else
            errors[:fasta_sequence] << "Please enter a fasta sequence and/or upload a fasta file"
            errors[:fasta_file] << "Please enter a fasta sequence and/or upload a fasta file"
        end
    end
    
    def validate_fasta_sequence
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
                illegal_characters_string = find_illegal_characters(tmp_sequence,:protein)
                errors[:fasta_sequence] << "Your fasta sequence seems to " +
                    "have the following invalid characters in it: " +
                    "#{illegal_characters_string}. Please see the fasta format" +
                    "specification."
            end
        #Validate that the sequence is a nucleotide sequence if that is what
        #   the blast program expects
        else
            if ( not (tmp_sequence =~/\A[ATGCX\-]+\z/i))
                illegal_characters_string = find_illegal_characters(tmp_sequence,:nucleotide)
                errors[:fasta_sequence] << "Your fasta sequence seems to " +
                    "have the following invalid characters in it: " +
                    "#{illegal_characters_string}. If you want to do a " +
                    "protein query, please select the blastp or tblastn program. " +
                    "Otherwise, see the fasta format specification."
            end
        end
        #Validate that the subsequence range is within the range of the actual sequence
        if not self.subsequence_to.empty?
            if tmp_sequence.length <self.subsequence_to.to_i
                errors[:subsequence_to] << "The subsequence upper bound cannot be greater " +
                    "than the length of the fasta sequence (" + tmp_sequence.length.to_s + ")"
            end
        end            
    end
    
    def validate_fasta_file
        #Declare some variables
        sequence_length = 0
        #sequence_type
        generic_error_message = "Parsing stopped at Line %d: Your fasta file seems to have the " +
            "following invalid characters in it: %s. Please see the fasta " + 
            "format specification and ensure that you have the right program selected." 
        #Declare some regular expressions
        description_line_regexp = Regexp.new('^([>].*)$','i')
        blank_line_regexp = Regexp.new('^$')
        sequence_line_regexpes = {}
        sequence_line_regexpes[:protein] = Regexp.new('^([ABCDEFGHIKLMNPQRSTUVWYZX*\-]+)$','i')
        sequence_line_regexpes[:nucleotide] = Regexp.new('^([ATGCX\-]+)$','i')
        #Determine whether to validate for a protein or nucleotide sequence 
        #    based on the program that the user selected
        if (self.program == :blastp or self.program == :tblastn)
            sequence_type = :protein
        else
            sequence_type = :nucleotide
        end
        #Declare some more variables
        line_count = 0
        previous_line = nil
        #Loop through the file, validating it and stopping if any errors are found
        while (not self.fasta_file.tempfile.eof?)
            line = self.fasta_file.tempfile.readline
            line_count+=1
            if (previous_line.nil?  or previous_line == :blank_line or previous_line == :sequence_line)
                if (line =~ description_line_regexp)
                    previous_line = :description_line
                elsif (line =~ blank_line_regexp)
                    previous_line = :blank_line
                elsif (line =~ sequence_line_regexpes[sequence_type])
                    previous_line = :sequence_line
                    sequequence_length+=line.length
                else
                    illegal_characters_string = find_illegal_characters(line,:protein)
                    errors[:fasta_file] << generic_error_message % [line_count, illegal_characters_string]
                    return
                end
            elsif (previous_line == :description_line)
                if (line =~ description_line_regexp)
                    errors[:fasta_file] << "Cannot have two description lines in a row"
                    return
                elsif (line =~ blank_line_regexp)
                    errors[:fasta_file] << "Parsing stopped at line #{line_count}: Cannot have a blank line after a description line. " + 
                        "Have a sequence line instead."
                    return
                elsif (line =~ sequence_line_regexp)
                    previous_line = :sequence_line
                    sequequence_length+=line.length
                else    #something is invalid
                    illegal_characters_string = find_illegal_characters(line,:protein)
                    errors[:fasta_file] << generic_error_message % [line_count, illegal_characters_string]
                    return
                end
            end
        end 
        #Validate that the subsequence range is within the range of the actual sequence
        if not self.subsequence_to.empty?
            if (self.subsequence_to > sequence_length)
                errors[:subsequence_to] << "The subsequence upper bound cannot be greater " +
                    "than the length of the fasta sequence (" + sequence_length + ")"
            end
        end
    end
    
    #find illegal characters in fasta sequence
    def find_illegal_characters(sequence,sequence_type)
        if (sequence_type == :nucleotide)
            regexp = Regexp.new("([^ATGCX\-])","i")
        #Protein
        else
            regexp= Regexp.new("([^ABCDEFGHIKLMNPQRSTUVWYZX*\-])","i")
        end
        illegal_characters = sequence.scan(regexp).uniq.flatten
        illegal_characters_string=""
        illegal_characters.each do |i|
            illegal_characters_string+=i
        end
        return illegal_characters_string
    end
    
    def validate_subsequences
        #Validate that subsequences are above 0 if there are filled in
        if (not self.subsequence_from.empty?)
            if (self.subsequence_from.to_i < 1)
                errors[:subsequence_from] << "Must be greater than 1"
            end
        end
        if (not self.subsequence_to.empty?)
            if (self.subsequence_to.to_i < 1)
                errors[:subsequence_to] << "Must be greater than 1"
            end
        end
        #Validate the subsequence_to is greater than subsequence_from if they both exist
        if (not self.subsequence_from.empty? and not self.subsequence_to.empty?)
            if (self.subsequence_from > self.subsequence_to)
                errors[:subsequence_from] << "Must be less than subsequence to"
                errors[:subsequence_to] << "Must be greater than subsequence from"
            end
        end
    end
end 
