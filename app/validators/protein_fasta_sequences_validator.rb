class ProteinFastaSequencesValidator < ActiveModel::EachValidator
  PROTEIN_REGEX = /\A[ABCDEFGHIKLMNPQRSTUVWYZX\*\-]+\z/i
  
  def validate_each(record, attribute, value)
    return if value.blank?
    #Parse fasta sequence to validate it
    tmp_sequence = value.clone()
    tmp_sequence.gsub!(/^([>].+)$/,'')    #remove description lines
    tmp_sequence.gsub!(/\n|\r/,'') #remove the newlines
    #Validate that sequence is a protein sequence if that is what
    #   the blast program expects
    if (tmp_sequence.empty? or tmp_sequence !~ PROTEIN_REGEX)
      record.errors[attribute] << "must contain one or more protein fasta sequences"
    end
  end
end


