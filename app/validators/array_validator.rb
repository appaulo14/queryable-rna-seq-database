class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    if not value.kind_of? Array
      record.errors[attribute] << "must be an array."
    end
  end
end