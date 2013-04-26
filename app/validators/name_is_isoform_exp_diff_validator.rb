class NameIsIsoformExpDiffValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return if not value.kind_of? ActionDispatch::Http::UploadedFile
    if (value.original_filename != 'isoform_exp.diff')
      record.errors[attribute] << "must be the isoform_exp.diff file."
    end
  end
end
