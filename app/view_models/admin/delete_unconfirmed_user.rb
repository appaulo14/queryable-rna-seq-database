###
# View model for the delete unconfirmed user page.
#
# <b>Associated Controller:</b> AdminController
class DeleteUnconfirmedUser
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
  # Sends an email to the user telling them that their registration request 
  # has been denied.
  def send_rejection_email_and_destroy_user
    return if not self.valid?
    RegistrationMailer.notify_user_of_rejection(user, @optional_note_to_user)
    user.destroy
  end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
end
