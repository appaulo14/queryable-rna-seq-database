class ReportIssue
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include SimpleCaptcha::ModelHelpers
  extend ActiveModel::Naming
  apply_simple_captcha
  
  attr_accessor :name, :email, :category, :when_issue_occured,
                  :description, :captcha
  attr_reader   :available_categories

  AVAILABLE_CATEGORIES = [
    'Applying For An Account',
    'Uploading Cuffdiff Data',
    'Uploading Trinity With EdgeR Data',
    'Uploading Fasta Sequences (Any Program)',
    'Querying for Gene Differential Expression Tests',
    'Querying for Transcript Differential Expression Tests',
    'Querying for Transcript Isoforms',
    'Querying With Blastn',
    'Querying With TBlastn',
    'Querying With TBlastx',
    'Other'
  ]
  
  validates :name, :presence => true
  validates :email, :presence => true,
                    :format => /\A[^@]+@[^@]+\z/
  validates :category, :presence => true,
                       :inclusion => {:in => AVAILABLE_CATEGORIES}
  validates :when_issue_occured, :presence => true                    
  validates :description, :presence => true

  def initialize(current_user)
    @current_user = current_user
  end
  
  def set_attributes_and_defaults(attributes = {})
    if not attributes.empty?
      year = attributes['when_issue_occured(1i)'].to_i
      month = attributes['when_issue_occured(2i)'].to_i
      day = attributes['when_issue_occured(3i)'].to_i
      hour = attributes['when_issue_occured(4i)'].to_i
      minute = attributes['when_issue_occured(5i)'].to_i
      @when_issue_occured = DateTime.new(year,month,day,hour,minute)
    else
      @when_issue_occured = DateTime.now
    end
    #Load in any values from the form
    attributes.each do |name, value|
        next if name.match(/when_issue_occured/)
        send("#{name}=", value)
    end
    #Set available categories
    @available_categories = AVAILABLE_CATEGORIES
    if not @current_user.nil?
      @name = @current_user.name
      @email = @current_user.email
    end
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
