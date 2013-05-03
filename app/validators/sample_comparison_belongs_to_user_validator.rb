###
# Validator class to verify that SampleComparison for the sample comparison id 
# being validated is owned by the current user.
class SampleComparisonBelongsToUserValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    current_user = record.instance_eval('@current_user')
    sample_comparison = SampleComparison.find_by_id(value)
    return if sample_comparison.nil?
    if sample_comparison.sample_1.dataset.user.id != current_user.id
      record.errors[attribute] << "must belong to you."
    end
  end
end
