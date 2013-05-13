require 'query/transcript_name_query_condition_generator.rb'
require 'query_analysis/abstract_query_regular_db.rb'

###
# View model for the query differentially expressed transcripts page.
#
# <b>Associated Controller:</b> QueryAnalysisController
class QueryDiffExpTranscripts < AbstractQueryRegularDb
 
  # The id of the sample comparison whose transript differential expression tests 
  # will be queried.
  attr_accessor :sample_comparison_id
  # Whether the cutoff should be by fdr or p_value
  attr_accessor :fdr_or_p_value
  # The cutoff where differential expression tests with an fdr_or_p_value 
  # above this will not be included in the query results 
  attr_accessor :cutoff
  # Specifies that only records matching this transcript name should be display 
  # in the query results.
  attr_accessor :transcript_name
  
  
  # The available sample comparisons for the selected dataset. These consist of 
  # any two samples that have transcript differential expression tests between them.
  attr_reader   :available_sample_comparisons
  # The name of the first sample in the sample comparison
  attr_reader   :sample_1_name
  # The name of the second sample in the sample comparison
  attr_reader   :sample_2_name
  
  validates :sample_comparison_id, :presence => true,
                                   :sample_comparison_belongs_to_user => true,
                                   :numericality => {
                                          :only_integer => true, 
                                          :greater_than_or_equal => 0 
                                   }
  validates :cutoff, :presence => true,
                     :format => { :with => /\A\d*\.?\d*\z/ }
  
  
  protected
  
  ###
  # The string to use for the GROUP BY section of the query.
  # transcripts.id is at the end of the string to prevent a strange error 
  # with counting
  def self.group_by_string
    return "genes.name_from_program, " +
           "test_statistic, " +
           "p_value, " +
           "fdr, " +
           "sample_1_fpkm, " +
           "sample_2_fpkm, " +
           "log_fold_change, " +
           "test_status, " +
           "transcripts.name_from_program "
  end
  
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
    super
    @fdr_or_p_value = 'p_value' if fdr_or_p_value.blank?
    @cutoff = '0.05' if cutoff.blank?
  end

  def build_select_string()
    select_string = 'transcripts.name_from_program as transcript_name, ' +
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
  
  def execute_query()
    if @has_go_terms == true
      @results = DifferentialExpressionTest
        .joins(:transcript => [:gene])
        .joins(self.class.thgt_left_join_string)
        .joins(self.class.go_terms_left_join_string)
        .where(@where_clauses)
        .group(self.class.group_by_string)
        .having(@having_string)
        .select(@select_string)
        .order(@order_string)
        .limit(self.class.page_size)
        .offset(self.class.page_size*(@page_number.to_i-1))
    else
      @results = DifferentialExpressionTest
        .joins(:transcript => [:gene])
        .where(@where_clauses)
        .group(self.class.group_by_string)
        .having(@having_string)
        .select(@select_string)
        .order(@order_string)
        .limit(self.class.page_size)
        .offset(self.class.page_size*(@page_number.to_i-1))
    end
  end
  
  def count_query_results()
    if @has_go_terms == true
      @results_count = DifferentialExpressionTest
        .joins(:transcript => [:gene])
        .joins(self.class.thgt_left_join_string)
        .joins(self.class.go_terms_left_join_string)
        .where(@where_clauses)
        .group(self.class.group_by_string)
        .having(@having_string)
        .select(@select_string)
        .order(@order_string)
        .count.count
    else
      @results_count = DifferentialExpressionTest
        .joins(:transcript => [:gene])
        .where(@where_clauses)
        .group(self.class.group_by_string)
        .having(@having_string)
        .select(@select_string)
        .order(@order_string)
        .count.count
    end
    if @results_count == 0
      available_page_numbers = [1]
    else
      @available_page_numbers = (1..(@results_count.to_f/self.class.page_size.to_f).ceil).to_a
    end
  end
end
