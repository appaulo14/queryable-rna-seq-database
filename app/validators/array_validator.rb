###
# Validator class to verify that the item being validated is an array.
class ArrayValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    if not value.kind_of? Array
      record.errors[attribute] << "must be an array."
    end
  end
end
