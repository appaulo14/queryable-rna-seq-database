class DatasetBelongsToUserValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    current_user = record.instance_eval('@current_user')
    if current_user.datasets.find_by_id(value).nil?
      record.errors[attribute] << "must belong to you."
    end
  end
end
