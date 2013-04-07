class GoIdsQueryConditionGenerator
  include ActiveModel::Validations
  
  attr_accessor :go_ids
  
  validates :go_ids, :presence => true
  
  def initialize(go_ids_string)
    @go_ids = go_ids_string
  end
  
  def generate_query_condition
    #Do some validation
    if not self.valid?
      raise ArgumentError.new(self.errors.full_messages)
    end
    #Generate and return the query condition
    go_ids = @go_ids.split(';')
    gt_t = GoTerm.arel_table
    where_clauses = []
    go_ids.each do |go_id|
      where_clauses << gt_t[:id].eq(go_id.strip)
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
