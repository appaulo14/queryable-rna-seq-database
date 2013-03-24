class DeleteUnconfirmedUser
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :user_id, :optional_note_to_user
  
  attr_reader :user
  
  validates :user_id, :presence => true
  validates :user, :presence => true,
                   :unconfirmed_user => true
  
  def initialize(attributes = {})
    #Load in any values from the form
      attributes.each do |name, value|
          send("#{name}=", value)
      end
      @user = User.find_by_id(@user_id)
  end
  
  def send_send_rejection_email_and_destroy_user
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
