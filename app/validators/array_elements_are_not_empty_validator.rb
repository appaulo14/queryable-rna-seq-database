class ArrayElementsAreNotEmptyValidator < ActiveModel::EachValidator
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
