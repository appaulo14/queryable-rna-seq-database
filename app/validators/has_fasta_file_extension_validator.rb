###
# Validator class to verify that an upload file is a fasta file by checking 
# its file extension.
class HasFastaFileExtensionValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    if (value.original_filename !~ /\A.+[.](?:fasta|fa)\z/i)
      record.errors[attribute] << "must be a fasta file."
    end
  end
end


