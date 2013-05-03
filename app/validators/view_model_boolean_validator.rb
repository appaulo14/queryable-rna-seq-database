###
# Validator class to verify that the value is either "1" or "0", which is 
# how booleans are stored in view models. 
class ViewModelBooleanValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    if value != '1' and value != '0'
      record.errors[attribute] << "must be either checked or unchecked"
    end
  end
end
