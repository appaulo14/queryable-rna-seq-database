class GoFilterChecker
  attr_reader :transcript_go_terms
  
  def initialize(transcript_id, go_ids, go_terms)
    @transcript_id = transcript_id
    @go_ids = go_ids
    @go_terms = go_terms
  end
  
  def passes_go_filters()
    transcript = Transcript.find_by_id(@transcript_id)
    @transcript_go_terms = transcript.go_terms
    return true if @go_ids.blank? and @go_terms.blank?
    return false if transcript_go_terms.empty?
    if not @go_ids.blank? and not @go_terms.blank?
      giqcg = GoIdsQueryConditionGenerator.new(@go_ids)
      gtqcg = GoTermsQueryConditionGenerator.new(@go_terms)
      where_clauses = giqcg.generate_query_condition()
      where_clauses = where_clauses.and(gtqcg.generate_query_condition())
      return false if (@transcript_go_terms & GoTerm.where(where_clauses)).empty?
    end
    if not @go_ids.blank?
      giqcg = GoIdsQueryConditionGenerator.new(@go_ids)
      query_condition = giqcg.generate_query_condition()
      return false if (@transcript_go_terms & GoTerm.where(query_condition)).empty?
    end
    if not @go_terms.blank?
      gtqcg = GoTermsQueryConditionGenerator.new(@go_terms)
      query_condition = gtqcg.generate_query_condition()
      return false if (@transcript_go_terms & GoTerm.where(query_condition)).empty?
    end
    return true
  end
end
