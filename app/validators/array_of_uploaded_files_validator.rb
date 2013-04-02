class ArrayOfUploadedFilesValidator < ActiveModel::EachValidator
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
