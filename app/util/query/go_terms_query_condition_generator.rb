###
# Utility class to create a where clause query condition to 
# match one or more GO terms (names).
class GoTermsQueryConditionGenerator
  include ActiveModel::Validations
  
  # The string containing the go term or group of go terms to use when 
  # creating the query condition
  attr_accessor :go_terms
  
  validates :go_terms, :presence => true
  
  ###
  # parameters::
  # * <b>go_terms_string:</b> The string containing the go term or group of 
  #   go terms to use when creating the query condition
  def initialize(go_terms_string)
    @go_terms = go_terms_string
  end
  
  ###
  # Generates and returns the actual where clause query condition.
  def generate_having_string()
    #Do some validation
    if not self.valid?
      raise ArgumentError.new(self.errors.full_messages)
    end
    having_string = ""
    # string_agg(go_terms.id,';') LIKE '%GO:0070373%' AND string_agg(go_terms.id,';') LIKE '%GO:0010540%'
    go_terms = @go_terms.split(';')
    go_terms.each do |go_term|
      # Strip and quote to help prevent sql injection attacks
      go_term =  ActiveRecord::Base.connection.quote_string(go_term.strip())
      if not having_string.strip.blank?
        having_string += " AND "
      end
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        having_string += "group_concat(go_terms.term SEPARATOR ';') LIKE '%#{go_term}%' "
      when /postgresql/
        having_string += "string_agg(go_terms.term,';') LIKE '%#{go_term}%' "
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end   
    end
    return having_string
  end
end
