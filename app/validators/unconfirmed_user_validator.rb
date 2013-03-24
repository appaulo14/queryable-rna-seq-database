class UnconfirmedUserValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    if not value.confirmed_at.nil?
      record.errors[attribute] << "must be an unconfirmed user."
    end
  end
end
