###
# Validator class to verify that an array contains uploaded file objects.
class ArrayOfUploadedFilesValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    return if not value.kind_of? Array
    value.each do |item| 
      if not item.kind_of? ActionDispatch::Http::UploadedFile
        record.errors[attribute] << "must have uploaded files."
        return
      end
    end
  end
end
