class NucleotideFastaSequencesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    #Parse fasta sequence to validate it
    tmp_sequence = self.fasta_sequence
    tmp_sequence.gsub!(/^([>].+)$/,'')    #remove description lines
    tmp_sequence.gsub!(/\n|\r/,'') #remove the newlines
    #Validate that sequence is a protein sequence if that is what
    #   the blast program expects
    if (tmp_sequene.empty? or tmp_sequence !~ /\A[ACGTNUKSYMWRBDHV\-]+\z/i)
      record.errors[attribute] << "must contain one or more nucleotide fasta sequences"
    end
  end
end


