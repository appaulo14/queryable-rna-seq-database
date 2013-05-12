require 'query/transcript_name_query_condition_generator.rb'
require 'query/go_ids_query_condition_generator.rb'
require 'query/go_terms_query_condition_generator.rb'
require 'query/go_filter_checker.rb'

###
# View model for the query differentially expressed transcripts page.
#
# <b>Associated Controller:</b> QueryAnalysisController
class QueryDiffExpTranscripts
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  # The id of the dataset whose transcript differential expression tests will be 
  # queried.
  attr_accessor :dataset_id
  # The id of the sample comparison whose transript differential expression tests 
  # will be queried.
  attr_accessor :sample_comparison_id
  # Whether the cutoff should be by fdr or p_value
  attr_accessor :fdr_or_p_value
  # The cutoff where differential expression tests with an fdr_or_p_value 
  # above this will not be included in the query results 
  attr_accessor :cutoff
  # Specifies that only the differential expression tests with transcripts that 
  # have all of these go terms (names) should be displayed in the 
  # query results.
  attr_accessor :go_terms
  # Specifies that only the differential expression tests with transcripts that 
  # have all of these go ids (accessions) should be displayed in the 
  # query results.
  attr_accessor :go_ids
  # Specifies that only records matching this transcript name should be display 
  # in the query results.
  attr_accessor :transcript_name
  # Because the query results are loaded in pieces using LIMIT and OFFSET, 
  # this specifies which piece to load.
  attr_accessor :page_number
  attr_accessor :sort_order
  attr_accessor :sort_column
  
  # The name/id pairs of the datasets that can be selected to have their 
  # transcript differential expression tests queried.
  attr_reader   :names_and_ids_for_available_datasets
  # The available sample comparisons for the selected dataset. These consist of 
  # any two samples that have transcript differential expression tests between them.
  attr_reader   :available_sample_comparisons
  # Contains the results from the query
  attr_reader   :results
  # The name of the first sample in the sample comparison
  attr_reader   :sample_1_name
  # The name of the second sample in the sample comparison
  attr_reader   :sample_2_name
  # The program used when generating the dataset's data, such as Cuffdiff or 
  # Trinity with EdgeR
  attr_reader   :program_used
  # Whether the select dataset has go terms
  attr_reader   :has_go_terms
  attr_reader   :show_results
  attr_reader   :available_sort_columns
  attr_reader   :available_sort_orders
  attr_reader   :available_page_numbers
  attr_reader   :results_count
  
  # The number of records in each piece of the query. This is used to 
  # determine the values for LIMIT and OFFSET in the query itself.
  PAGE_SIZE = 50
  
  AVAILABLE_SORT_ORDERS = {'ascending' => 'ASC', 'descending' => 'DESC'}
  
  # The string to use for the GROUP BY section of the query.
  # transcripts.id is at the end of the string to prevent a strange error 
  # with counting
  GROUP_BY_STRING = "genes.name_from_program, " +
                    "test_statistic, " +
                    "p_value, " +
                    "fdr, " +
                    "sample_1_fpkm, " +
                    "sample_2_fpkm, " +
                    "log_fold_change, " +
                    "test_status, " +
                    "transcripts.id "
  
  THGT_LEFT_JOIN_STRING = "LEFT OUTER JOIN transcript_has_go_terms " +
                  "ON transcript_has_go_terms.transcript_id = transcripts.id"
  
  GO_TERMS_LEFT_JOIN_STRING = "LEFT OUTER JOIN go_terms " +
                  "ON transcript_has_go_terms.go_term_id = go_terms.id"
  
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true,
                         :numericality => {
                              :only_integer => true, 
                              :greater_than_or_equal => 0 
                          }
  validates :sample_comparison_id, :presence => true,
                                   :sample_comparison_belongs_to_user => true,
                                   :numericality => {
                                          :only_integer => true, 
                                          :greater_than_or_equal => 0 
                                   }
  validates :cutoff, :presence => true,
                     :format => { :with => /\A\d*\.?\d*\z/ }
  
  
  def show_results?
    return @show_results
  end
  
  ###
  # parameters::
  # * <b>current_user:</b> The currently logged in user
  def initialize(current_user)
    @current_user = current_user
  end
  
  # Set the view model's attributes or set those attributes to their 
  # default values
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    set_available_datasets_and_default_dataset()
    set_sample_related_defaults()
    set_sort_defaults()
    set_other_defaults()
  end
  
  # Execute the query to get the transcript differential expression tests 
  # with the specified filtering options and store them in #results.
  def query()
    #Don't query if it is not valid
    return if not self.valid?
    record_that_dataset_has_been_queried()
    build_query_parts()
    execute_query()
    count_query_results()
    @show_results = true
  end
  
  ###
  # According to http://railscasts.com/episodes/219-active-model?view=asciicast,
  # this defines that this view model does not persist in the database.
  def persisted?
      return false
  end
  
  private
  
  def set_available_datasets_and_default_dataset()
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
    end
    @dataset = Dataset.find_by_id(@dataset_id)
  end
  
  def set_sample_related_defaults()
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
    sample_comparisons_query.each do |scq|
      display_text = "#{scq.sample_1_name} vs #{scq.sample_2_name}"
      value = scq.sample_comparison_id
      @available_sample_comparisons << [display_text, value]
    end
    @available_sample_comparisons.sort!{|t1,t2|t1[0] <=> t2[0]}
    if @sample_comparison_id.blank?
      @sample_comparison_id = @available_sample_comparisons[0][1]
    end
    sample_cmp = SampleComparison.find_by_id(@sample_comparison_id)
    @sample_1_name = sample_cmp.sample_1.name
    @sample_2_name = sample_cmp.sample_2.name
  end
  
  def set_sort_defaults()
    @available_sort_orders = AVAILABLE_SORT_ORDERS.keys
    if @program_used == 'cuffdiff'
      @available_sort_columns = ['Transcript','Associated Gene', 
                                 'Test Statistic', 'P-value','FDR', 
                                "#{@sample_1_name} FPKM", 
                                "#{@sample_2_name} FPKM", 'Log Fold Change',
                                'Test Status']
    else
      @available_sort_columns = ['Transcript','Associated Gene', 'P-value',
                                 'FDR', 
                                "#{@sample_1_name} FPKM", 
                                 "#{@sample_2_name} FPKM",
                                'Log Fold Change']
    end
    @sort_order = @available_sort_orders.first if @sort_order.blank?
    @sort_column = @available_sort_columns.first if @sort_column.blank?
  end
  
  def set_other_defaults()
    @program_used = @dataset.program_used
    @has_go_terms = (@dataset.go_terms_status == 'done') ? true : false
    @page_number = '1' if @page_number.blank?
    @fdr_or_p_value = 'p_value' if fdr_or_p_value.blank?
    @cutoff = '0.05' if cutoff.blank?
    @show_results = false if @show_results.blank?
  end
  
  def record_that_dataset_has_been_queried()
    @dataset.when_last_queried = Time.now
    @dataset.save!
  end
  
  def build_select_string()
    select_string = 'transcripts.id as transcript_id,' +
                    'transcripts.name_from_program as transcript_name, ' +
                    'genes.name_from_program as gene_name,' +
                    'differential_expression_tests.test_statistic,' +
                    'differential_expression_tests.p_value,' +
                    'differential_expression_tests.fdr,' +
                    'differential_expression_tests.sample_1_fpkm,' +
                    'differential_expression_tests.sample_2_fpkm,' +
                    'differential_expression_tests.log_fold_change,' +
                    'differential_expression_tests.test_status '
    if @has_go_terms == true
      select_string += ', '
      # Add aggregate select string for the go ids
      go_ids_agg_str_gen = AggregateStringGenerator.new('go_terms.id','go_ids')
      select_string += "#{go_ids_agg_str_gen.generate_aggregate_string()}, "
      # Add the aggregate select string for the go terms
      go_terms_agg_str_gen = AggregateStringGenerator.new('go_terms.term',
                                                          'go_terms')
      select_string += go_terms_agg_str_gen.generate_aggregate_string()
    end
    return select_string
  end
  
  def build_order_string()
    case @sort_column
    when'Transcript'
      sort_column = 'transcripts.name_from_program'
    when 'Associated Gene'
      sort_column = 'genes.name_from_program'
    when 'Test Statistic'
      sort_column = 'differential_expression_tests.test_statistic'
    when 'P-value'
      sort_column = 'differential_expression_tests.p_value'
    when 'FDR'
      sort_column = 'differential_expression_tests.fdr'
    when "#{@sample_1_name} FPKM"
      sort_column = 'differential_expression_tests.sample_1_fpkm'
    when "#{@sample_2_name} FPKM"
      sort_column = 'differential_expression_tests.sample_2_fpkm'
    when 'Log Fold Change'
      sort_column = 'differential_expression_tests.log_fold_change'
    when 'Test Status'
      sort_column = 'differential_expression_tests.test_status'
    end
    return "#{sort_column} #{AVAILABLE_SORT_ORDERS[@sort_order]}"
  end
  
  def generate_where_clauses()
    #Require parts of the where clause
    det_t = DifferentialExpressionTest.arel_table
    where_clauses = det_t[:sample_comparison_id].eq(@sample_comparison_id)
    if @fdr_or_p_value == 'p_value'
      where_clauses = where_clauses.and(det_t[:p_value].lteq(@cutoff))
    else
      where_clauses = where_clauses.and(det_t[:fdr].lteq(@cutoff))
    end
    #Optional parts of the where clause
    if not @transcript_name.strip.blank?
      tnqcg = TranscriptNameQueryConditionGenerator.new()
      tnqcg.name = @transcript_name
      where_clauses = where_clauses.and(tnqcg.generate_query_condition())
    end
    return where_clauses
  end
  
  def generate_having_string()
    return "" if @has_go_terms == false
    having_string = ""
    if not @go_ids.strip.blank?
      giqcg = GoIdsQueryConditionGenerator.new(@go_ids)
      having_string += giqcg.generate_having_string()
    end
    if not @go_terms.strip.blank?
      gtqcg = GoTermsQueryConditionGenerator.new(@go_terms)
      if not having_string.strip.blank?
        having_string += " AND "
      end
      having_string += gtqcg.generate_having_string()
    end
    return having_string
  end
  
  def build_query_parts()
    @select_string = build_select_string()
    @where_clauses = generate_where_clauses()
    @having_string = generate_having_string()
    @order_string = build_order_string()
  end
  
  def execute_query()
    if @has_go_terms == true
      @results = DifferentialExpressionTest
        .joins(:transcript => [:gene])
        .joins(THGT_LEFT_JOIN_STRING)
        .joins(GO_TERMS_LEFT_JOIN_STRING)
        .where(@where_clauses)
        .group(GROUP_BY_STRING)
        .having(@having_string)
        .select(@select_string)
        .order(@order_string)
        .limit(PAGE_SIZE)
        .offset(PAGE_SIZE*(@page_number.to_i-1))
    else
      @results = DifferentialExpressionTest
        .joins(:transcript => [:gene])
        .where(@where_clauses)
        .group(GROUP_BY_STRING)
        .having(@having_string)
        .select(@select_string)
        .order(@order_string)
        .limit(PAGE_SIZE)
        .offset(PAGE_SIZE*(@page_number.to_i-1))
    end
  end
  
  def count_query_results()
    if @has_go_terms == true
      @results_count = DifferentialExpressionTest
        .joins(:transcript => [:gene])
        .joins(THGT_LEFT_JOIN_STRING)
        .joins(GO_TERMS_LEFT_JOIN_STRING)
        .where(@where_clauses)
        .group(GROUP_BY_STRING)
        .having(@having_string)
        .select(@select_string)
        .order(@order_string)
        .count.count
    else
      @results_count = DifferentialExpressionTest
        .joins(:transcript => [:gene])
        .where(@where_clauses)
        .group(GROUP_BY_STRING)
        .having(@having_string)
        .select(@select_string)
        .order(@order_string)
        .count.count
    end
    if @results_count == 0
      available_page_numbers = [1]
    else
      @available_page_numbers = (1..(@results_count.to_f/PAGE_SIZE.to_f).ceil).to_a
    end
  end
end
