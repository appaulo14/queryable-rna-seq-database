###
# Validator class to verify that the value being validated is a valid 
# protein fasta sequence or group of fasta sequences.
class ProteinFastaSequencesValidator < ActiveModel::EachValidator
  # Regular expression containing all the valid characters in a protein fasta 
  # sequence, excluding the definition line
  PROTEIN_REGEX = /\A[ABCDEFGHIKLMNPQRSTUVWYZX\*\-]+\z/i
  
  ### 
  # The method that actually does the validation
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


