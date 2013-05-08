###
# Validator class to verify that an uploaded file has the name "Trinity.fasta".
class NameIsTrinityFastaValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    return if not value.kind_of? ActionDispatch::Http::UploadedFile
    if (value.original_filename != 'Trinity.fasta')
      record.errors[attribute] << "must be the Trinity.fasta file."
    end
  end
end
