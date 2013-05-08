###
# View model for the confirm user page.
#
# <b>Associated Controller:</b> AdminController
class ConfirmUser
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  # The id of the user to be confirmed
  attr_accessor :user_id
  # An optional note to be emailed to the user
  attr_accessor :optional_note_to_user
  # The user to be confirmed
  attr_reader :user
  
  validates :user_id, :presence => true
  validates :user, :presence => true,
                   :unconfirmed_user => true
  
  ###
  # parameters::
  # * <b>attributes:</b> A hash containing any instance attributes
  def initialize(attributes = {})
    #Load in any values from the form
      attributes.each do |name, value|
          send("#{name}=", value)
      end
      @user = User.find_by_id(@user_id)
  end
  
  ###
  # Send the two confirmation emails to the user who was just confirmed. 
  # The first email tells the user they have been confirmed 
  # and contains an optional note from the administrator to the user.
  # The second email is sent using the Devise gem and contains the confirmation 
  # instructions that actually allow the user to activate their account. 
  def send_confirmation_emails
    return if not self.valid?
    RegistrationMailer.notify_user_that_confirmation_email_will_be_sent(user,
                                                        @optional_note_to_user)
    user.send_confirmation_instructions
  end
  
  # Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  # this defines that this model does not persist in the database.
  def persisted?
    return false
  end
end
