class UploadedFileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    if not value.kind_of? ActionDispatch::Http::UploadedFile
      record.errors[attribute] << "must be an uploaded file."
    end
  end
end
