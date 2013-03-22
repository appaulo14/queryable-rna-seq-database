class ReportIssue
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :name, :email, :category, :datetime_when_issue_occured,
                  :description
  attr_reader   :available_categories

  def initialize(current_user)
    @current_user = current_user
  end
  
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    #Set available categories
    @available_categories = []
  end
  
  def report_issue()
    #Don't query if it is not valid
    return if not self.valid?
    #Send email
    HomeMailer.send_report_on_issue(self)
  end
  
  #According http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
end
