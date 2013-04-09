class NameIsTrinityFastaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return if not value.kind_of? ActionDispatch::Http::UploadedFile
    if (value.original_filename != 'Trinity.fasta')
      record.errors[attribute] << "must be the Trinity.fasta file."
    end
  end
end
