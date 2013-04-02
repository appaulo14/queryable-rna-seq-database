class ViewModelBooleanValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    if value != '1' and value != '0'
      record.errors[attribute] << "must be either checked or unchecked"
    end
  end
end
