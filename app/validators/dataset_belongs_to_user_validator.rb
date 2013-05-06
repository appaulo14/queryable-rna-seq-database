###
# Validator class to verify that the Dataset for the dataset id being validated 
# is owned by the current user.
class DatasetBelongsToUserValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    current_user = record.instance_eval('@current_user')
    if current_user.datasets.find_by_id(value).nil?
      record.errors[attribute] << "must belong to you."
    end
  end
end
