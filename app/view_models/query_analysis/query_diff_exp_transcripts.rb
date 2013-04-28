require 'query/transcript_name_query_condition_generator.rb'
require 'query/go_ids_query_condition_generator.rb'
require 'query/go_terms_query_condition_generator.rb'

class QueryDiffExpTranscripts
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id, :sample_comparison_id,
                :fdr_or_p_value, :cutoff, :go_terms,
                :go_ids, :transcript_name, :piece
  attr_reader  :names_and_ids_for_available_datasets, 
                :available_sample_comparisons, 
                :show_results, :results, :sample_1_name, :sample_2_name,
                :program_used
  
  PIECE_SIZE = 100
  
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
    available_datasets = Dataset.where(:user_id => @current_user.id, 
                                       :has_transcript_diff_exp => true,
                                       :finished_uploading => true)
                                .order(:name)
    available_datasets.each do |ds|
      @names_and_ids_for_available_datasets << [ds.name, ds.id]
    end
    #Set default values for the relavent blank attributes
    if @dataset_id.blank?
      @dataset_id = available_datasets.first.id
    elsif not @dataset_id.to_s.match(/\A\d+\z/)
      @dataset_id = available_datasets.first.id
    end
    @fdr_or_p_value = 'p_value' if fdr_or_p_value.blank?
    @cutoff = '0.05' if cutoff.blank?
    #Set available samples for comparison
    @available_sample_comparisons = []
    s_t = Sample.arel_table
    where_clause = s_t[:dataset_id].eq(@dataset_id)
    sample_type_eq_both = s_t[:sample_type].eq('both')
    sample_type_eq_transcript = s_t[:sample_type].eq('transcript')
    sample_type_where_clause = sample_type_eq_transcript.or(sample_type_eq_both)
    where_clause = where_clause.and(sample_type_where_clause)
    sample_comparisons_query = SampleComparison.joins(:sample_1,:sample_2).
        where(where_clause).
        select('samples.name as sample_1_name, '+
               'sample_2s_sample_comparisons.name as sample_2_name, ' +
               'sample_comparisons.id as sample_comparison_id')
        .limit(PIECE_SIZE).offset(PIECE_SIZE*@piece.to_i)
    sample_comparisons_query.each do |scq|
      display_text = "#{scq.sample_1_name} vs #{scq.sample_2_name}"
      value = scq.sample_comparison_id
      @available_sample_comparisons << [display_text, value]
    end
    @available_sample_comparisons.sort!{|t1,t2|t1[0] <=> t2[0]}
    if @sample_comparison_id.blank?
      @sample_comparison_id = @available_sample_comparisons[0][1]
    end
    @show_results = false
    @program_used = Dataset.find_by_id(@dataset_id).program_used
  end
  
  def query()
    #Don't query if it is not valid
    return if not self.valid?
    #Record that the dataset was queried at this time
    ds = Dataset.find_by_id(@dataset_id)
    ds.when_last_queried = Time.now
    ds.save!
    #Retreive some variables to use later
    sample_comparison = SampleComparison.find_by_id(@sample_comparison_id)
    @sample_1_name = sample_comparison.sample_1.name
    @sample_2_name = sample_comparison.sample_2.name
    #Require parts of the where clause
    det_t = DifferentialExpressionTest.arel_table
    where_clause = det_t[:sample_comparison_id].eq(sample_comparison.id)
    if @fdr_or_p_value == 'p_value'
      where_clause = where_clause.and(det_t[:p_value].lteq(@cutoff))
    else
      where_clause = where_clause.and(det_t[:fdr].lteq(@cutoff))
    end
    #Optional parts of the where clause
    if not @transcript_name.blank?
      tnqcg = TranscriptNameQueryConditionGenerator.new()
      tnqcg.name = @transcript_name
      where_clause = where_clause.and(tnqcg.generate_query_condition())
    end
    query_results = 
      DifferentialExpressionTest.joins(:transcript).where(where_clause)
    #Extract the query results to a form that can be put in the view
    @results = []
    query_results.each do |query_result|
      #Fill in the result hash that the view will use to display the data
      transcript = Transcript.find_by_id(query_result.transcript_id)
      if not @go_ids.blank?
        giqcg = GoIdsQueryConditionGenerator.new(@go_ids)
        query_condition = giqcg.generate_query_condition()
        next if (transcript.go_terms & GoTerm.where(query_condition)).empty?
      end
      if not @go_terms.blank?
        gtqcg = GoTermsQueryConditionGenerator.new(@go_terms)
        query_condition = gtqcg.generate_query_condition()
        next if (transcript.go_terms & GoTerm.where(query_condition)).empty?
      end
      result = {}
      result[:transcript_name] = transcript.name_from_program
      if transcript.gene
        result[:gene_name] =  transcript.gene.name_from_program 
      end
      result[:go_terms] = transcript.go_terms
      result[:test_statistic] = query_result.test_statistic
      result[:p_value] = query_result.p_value
      result[:fdr] = query_result.fdr
      result[:sample_1_fpkm] =  query_result.sample_1_fpkm
      result[:sample_2_fpkm] =  query_result.sample_2_fpkm
      result[:log_fold_change] = query_result.log_fold_change
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
