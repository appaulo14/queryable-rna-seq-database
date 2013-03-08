class ConfirmUser
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :user_id, :optional_note_to_user
  
  
  def initialize(attributes = {})
    #Load in any values from the form
      attributes.each do |name, value|
          send("#{name}=", value)
      end
  end
  
  def send_confirmation_emails!
    #Get the transcripts from the parameters
    raise(ActiveRecord::RecordInvalid,self) if not self.valid?
    user = User.find_by_id(@user_id)
    RegistrationMailer.notify_user_that_confirmation_email_will_be_sent(user, @optional_note_to_user)
    user.send_confirmation_instructions
  end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
end
