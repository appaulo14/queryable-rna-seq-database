# Validator class to verify that the User being validated is an unconfirmed 
# user.
class UnconfirmedUserValidator < ActiveModel::EachValidator
  ### 
  # The method that actually does the validation
  def validate_each(record, attribute, value)
    return if value.blank?
    if not value.confirmed_at.nil?
      record.errors[attribute] << "must be an unconfirmed user."
    end
  end
end
