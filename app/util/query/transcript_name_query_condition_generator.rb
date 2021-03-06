###
# Utility class to create a where clause query condition to 
# match a specified gene name. 
class TranscriptNameQueryConditionGenerator
  include ActiveModel::Validations
  
  # The trancript name of to use when creating the query condition
  attr_accessor :name
  
  validates :name, :presence => true
  
  ###
  # parameters::
  # * <b>attributes:</b> A hash containing any instance attributes
  def initialize(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
  end
  
  ###
  # Generates and returns the actual where clause query condition.
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
