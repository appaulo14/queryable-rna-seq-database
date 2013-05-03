###
# Validator class to verify that an upload file has the name "isoform_exp.diff".
class NameIsIsoformExpDiffValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    return if not value.kind_of? ActionDispatch::Http::UploadedFile
    if (value.original_filename != 'isoform_exp.diff')
      record.errors[attribute] << "must be the isoform_exp.diff file."
    end
  end
end
