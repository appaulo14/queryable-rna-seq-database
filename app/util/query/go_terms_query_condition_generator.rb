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
  def generate_query_condition
    #Do some validation
    if not self.valid?
      raise ArgumentError.new(self.errors.full_messages)
    end
    go_terms = @go_terms.split(';')
    gt_t = GoTerm.arel_table
    where_clauses = []
    go_terms.each do |go_term|
      where_clauses << gt_t[:name].matches("%#{go_term.strip}%")
    end
    if where_clauses.count > 1
      combined_where_clause = where_clauses[0]
      (1..where_clauses.count-1).each do |i|
        combined_where_clause = combined_where_clause.and(where_clauses[i])
      end
      return combined_where_clause
    else
      return where_clauses[0]
    end
  end
end
