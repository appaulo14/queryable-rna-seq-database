###
# Validator class to see whether the transcript passes the filter of 
# containing the specified go terms and go ids. 
class GoFilterChecker
  # An array of all the GoTerm records for the Transcript
  attr_reader :transcript_go_terms
  
  ###
  # parameters::
  # * <b>transcript_id:</b> the id of the Transcript to check
  # * <b>go_ids:</b> a string containing the go ids to ensure the transcript has
  # * <b>go_terms:</b> a string containing the go terms to ensure the transcript has
  def initialize(transcript_id, go_ids, go_terms)
    @transcript_id = transcript_id
    @go_ids = go_ids
    @go_terms = go_terms
  end
  
  ###
  # Returns whether or not the transcript has the required go terms and go ids
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
