class DatasetNameUniqueForUserValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    current_user = record.instance_eval('@current_user')
    if current_user.datasets.find_by_name(value)
      record.errors[attribute] << "cannot have the same name as one of your other datasets."
    end
  end
end