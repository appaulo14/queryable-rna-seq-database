###
# A subclass of the Devise gem's confirmations controller. This subclass just 
# prevents a user from getting a confirmation email without the admin's 
# approval.
class ConfirmationsController < Devise::ConfirmationsController
  # Handles requests to create a new confirmation email. I overrode this 
  # action because the user shouldn't be allowed to do that in this project.
  def new
    redirect_to '/'
  end
end
