require 'query/transcript_name_query_condition_generator.rb'
require 'query/go_ids_query_condition_generator.rb'
require 'query/go_terms_query_condition_generator.rb'

class QueryDiffExpTranscripts
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id, :sample_comparison_id_pair,
                :fdr_or_p_value, :cutoff, :filter_by_go_terms, :go_terms,
                :filter_by_go_ids, :go_ids,
                :filter_by_transcript_name, :transcript_name 
  attr_reader  :names_and_ids_for_available_datasets, 
                :available_sample_comparisons, 
                :show_results, :results, :sample_1_name, :sample_2_name
  
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true
  
  
  def initialize(user)
    @current_user = user
  end
  
  def show_results?
    return @show_results
  end
  
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    #Set available datasets
    @names_and_ids_for_available_datasets = []
    all_datasets_for_current_user = 
        Dataset.find_all_by_user_id(@current_user.id)
    all_datasets_for_current_user.each do |ds|
      @names_and_ids_for_available_datasets << [ds.name, ds.id]
    end
    #Set default values for the relavent blank attributes
    @dataset_id = all_datasets_for_current_user.first.id if @dataset_id.blank?
    @fdr_or_p_value = :p_value if fdr_or_p_value.blank?
    @cutoff = '0.05' if cutoff.blank?
    @filter_by_go_terms = false if filter_by_go_terms.blank?
    @filter_by_go_ids = false if filter_by_go_ids.blank?
    @filter_by_transcript_name = false if filter_by_transcript_name.blank?
    #Set available samples for comparison
    @available_sample_comparisons = []
    sample_comparisons_query = SampleComparison.joins(:sample_1,:sample_2).
        where('samples.dataset_id' => @dataset_id).
        select('samples.name as sample_1_name, '+
               'sample_2s_sample_comparisons.name as sample_2_name, ' +
               'samples.id as sample_1_id, ' +
               'sample_2s_sample_comparisons.id as sample_2_id')
    sample_comparisons_query.each do |scq|
      display_text = "#{scq.sample_1_name} vs #{scq.sample_2_name}"
      value = "#{scq.sample_1_id},#{scq.sample_2_id}"
      @available_sample_comparisons << [display_text, value]
    end
    if @sample_comparison_id_pair.blank?
      @sample_comparison_id_pair = @available_sample_comparisons[0][1]
    end
    @show_results = false
  end
  
  def query()
    #Don't query if it is not valid
    return if not self.valid?
    #Retreive some variables to use later
    sample_ids = @sample_comparison_id_pair.split(',')
    sample_1 = Sample.find_by_id(sample_ids[0])
    sample_2 = Sample.find_by_id(sample_ids[1])
    sample_comparison = SampleComparison.where(
      :sample_1_id => sample_ids[0],
      :sample_2_id => sample_ids[1]
    )[0]
    #Require parts of the where clause
    det_t = DifferentialExpressionTest.arel_table
    #where_clause = det_t[:gene_id].eq(nil)
    where_clause = det_t[:sample_comparison_id].eq(sample_comparison.id)
    #where_clause = where_clause.and(sample_cmp_clause)
    if @fdr_or_p_value == 'p_value'
      where_clause = where_clause.and(det_t[:p_value].lteq(@cutoff))
    else
      where_clause = where_clause.and(det_t[:fdr].lteq(@cutoff))
    end
    #Optional parts of the where clause
    if @filter_by_transcript_name == '1'
      tnqcg = TranscriptNameQueryConditionGenerator.new()
      tnqcg.name = @transcript_name
      where_clause = where_clause.and(tnqcg.generate_query_condition())
    end
    query_results = 
      DifferentialExpressionTest.joins(:transcript).where(where_clause)
    #Extract the query results to a form that can be put in the view
    @sample_1_name = sample_1.name
    @sample_2_name = sample_2.name
    @results = []
    query_results.each do |query_result|
      #Fill in the result hash that the view will use to display the data
      transcript = Transcript.find_by_id(query_result.transcript_id)
      if @filter_by_go_ids == '1'
        giqcg = GoIdsQueryConditionGenerator.new(@go_ids)
        query_condition = giqcg.generate_query_condition()
        next if (transcript.go_terms & GoTerm.where(query_condition)).empty?
      end
      if @filter_by_go_terms == '1'
        gtqcg = GoTermsQueryConditionGenerator.new(@go_terms)
        query_condition = gtqcg.generate_query_condition()
        next if (transcript.go_terms & GoTerm.where(query_condition)).empty?
      end
      result = {}
      result[:transcript_name] = transcript.name_from_program #det.transcript.name_from_program
      result[:gene_name] = transcript.gene.name_from_program #det.transcript.gene.name_from_program
      result[:go_terms] = transcript.go_terms #det.transcript.go_terms
      result[:test_statistic] = query_result.test_statistic
      result[:p_value] = query_result.p_value #det.p_value
      result[:fdr] = query_result.fdr #det.fdr
      result[:sample_1_fpkm] =  query_result.sample_1_fpkm   #det.fpkm_sample_1.fpkm
      result[:sample_2_fpkm] =  query_result.sample_2_fpkm   #det.fpkm_sample_2.fpkm
      result[:log_fold_change] = query_result.log_fold_change     #det.logfc
      result[:test_status] = query_result.test_status
      @results << result
    end
    #Mark the search results as viewable
    @show_results = true
  end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
  
  private
  def user_has_permission_to_access_dataset
  end
  
  def user_has_permission_to_access_comparison
  end
end
