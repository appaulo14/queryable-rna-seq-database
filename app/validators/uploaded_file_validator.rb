###
# Validator class to verify that the value being validated is an uploaded 
# file object.
class UploadedFileValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    if not value.kind_of? ActionDispatch::Http::UploadedFile
      record.errors[attribute] << "must be an uploaded file."
    end
  end
end
