class SampleBelongsToUserValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    current_user = record.instance_eval('@current_user')
    sample = Sample.find_by_id(value)
    return if sample.nil?
    if sample.dataset.user.id != current_user.id
      record.errors[attribute] << "must belong to you."
    end
  end
end
