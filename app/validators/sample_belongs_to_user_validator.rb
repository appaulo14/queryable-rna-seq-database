###
# Validator class to verify that Sample for the sample id being validated 
# is owned by the current user.
class SampleBelongsToUserValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    current_user = record.instance_eval('@current_user')
    sample = Sample.find_by_id(value)
    return if sample.nil?
    if sample.dataset.user.id != current_user.id
      record.errors[attribute] << "must belong to you."
    end
  end
end
