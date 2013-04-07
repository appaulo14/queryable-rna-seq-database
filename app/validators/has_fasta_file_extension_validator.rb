class HasFastaFileExtensionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    if (value.original_filename !~ /\A.+[.](?:fasta|fa)\z/i)
      record.errors[attribute] << "must be a fasta file."
    end
  end
end


