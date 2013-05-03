###
# Validator class to verify that there are no blank elements in an array.
class ArrayElementsAreNotEmptyValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    return if not value.kind_of? Array
    value.each do |item| 
      if item.blank?
        record.errors[attribute] << "must have an entry in each one."
        return
      end
    end
  end
end
