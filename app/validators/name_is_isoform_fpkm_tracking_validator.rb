class NameIsIsoformFpkmTrackingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return if not value.kind_of? ActionDispatch::Http::UploadedFile
    if (value.original_filename != 'isoforms.fpkm_tracking')
      record.errors[attribute] << "must be the isoforms.fpkm_tracking file."
    end
  end
end
