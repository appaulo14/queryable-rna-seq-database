class TranscriptNameQueryConditionGenerator
  include ActiveModel::Validations
  
  attr_accessor :name
  
  validates :name, :presence => true
  
  def initialize(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
  end
  
  def generate_query_condition
    #Do some validation
    if not self.valid?
      raise ArgumentError.new(self.errors.full_messages)
    end
    #Generate and return the query condition
    t_t = Transcript.arel_table
    return t_t[:name_from_program].matches("%#{@name.strip}%")
  end
end
