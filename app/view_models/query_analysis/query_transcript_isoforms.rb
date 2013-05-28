require 'query/transcript_name_query_condition_generator.rb'
require 'query_analysis/abstract_query_regular_db.rb'

###
# View model for the query transcript isoforms page.
#
# <b>Associated Controller:</b> QueryAnalysisController
#
# <b>Associated Worker:</b> WorkerForQueryRegularDb
class QueryTranscriptIsoforms < AbstractQueryRegularDb
  
  # The id of the sample whose isoforms will be queried.
  attr_accessor :sample_id
  # Specifies that only transcripts with the "=" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_equal
  # Specifies that only transcripts with the "c" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_c
  # Specifies that only transcripts with the "j" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_j
  # Specifies that only transcripts with the "e" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_e
  # Specifies that only transcripts with the "i" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_i
  # Specifies that only transcripts with the "o" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_o
  # Specifies that only transcripts with the "p" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_p
  # Specifies that only transcripts with the "r" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_r
  # Specifies that only transcripts with the "u" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_u
  # Specifies that only transcripts with the "x" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_x
  # Specifies that only transcripts with the "s" class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_s
  # Specifies that only transcripts with the "." class code or other selected 
  # class codes should be displayed in the query results.
  attr_accessor :class_code_dot
  # Which comparison sign to use for filtering the transcript length
  attr_accessor :transcript_length_comparison_sign
  # The transcript length to filter by
  attr_accessor :transcript_length_value
  # Specifies that only records matching this transcript name should be display 
  # in the query results.
  attr_accessor :transcript_name
  
  # The available samples for the selected dataset.
  attr_reader   :available_samples
  # The available valid options for the transcript_length_comparison_sign attribute
  attr_reader   :available_transcript_length_comparison_signs
  # The name of the sample being queried
  attr_reader   :sample_name
  
  # Contains all the possible class codes and is used to build the where 
  # clause for the class code filtering options
  CLASS_CODES = {
    :class_code_equal => '=', 
    :class_code_c => 'c',
    :class_code_j => 'j',
    :class_code_e => 'e',
    :class_code_i => 'i',
    :class_code_o => 'o',
    :class_code_p => 'p',
    :class_code_r => 'r',
    :class_code_u => 'u',
    :class_code_x => 'x',
    :class_code_s => 's',
    :class_code_dot => '.'
  }
  
  # The available valid options for the transcript_length_comparison_sign attribute
  AVAILABLE_TRANSCRIPT_LENGTH_COMPARISON_SIGNS = ['>','>=','<','=<','=']

  validates :dataset_id, :presence => true,
                        :dataset_belongs_to_user => true
  validates :sample_id, :presence => true,
                        :sample_belongs_to_user => true
  validates :class_code_equal, :view_model_boolean => true
  validates :class_code_c, :view_model_boolean => true
  validates :class_code_j, :view_model_boolean => true
  validates :class_code_e, :view_model_boolean => true
  validates :class_code_i, :view_model_boolean => true
  validates :class_code_o, :view_model_boolean => true
  validates :class_code_p, :view_model_boolean => true
  validates :class_code_r, :view_model_boolean => true
  validates :class_code_u, :view_model_boolean => true
  validates :class_code_x, :view_model_boolean => true
  validates :class_code_s, :view_model_boolean => true
  validates :class_code_dot, :view_model_boolean => true
  validates :transcript_length_comparison_sign, 
     :inclusion => {:in => AVAILABLE_TRANSCRIPT_LENGTH_COMPARISON_SIGNS}
  validates :transcript_length_value, :numericality => true
  
  ###
  # Returns a list of the class codes that have been selected
  def list_selected_class_codes
    class_codes = []
    CLASS_CODES.each do |key, value|
      if self.send(key) == '1'
        class_codes << key
      end
    end
    return class_codes
  end
  
  ###
  # Returns the type of query that the class provides
  def self.get_query_type()
    return 'query_transcript_isoforms'
  end
  
  protected
  
  ###
  # The string to use for the GROUP BY section of the query.
  def self.group_by_string
    return 'genes.name_from_program,' +
           'transcript_fpkm_tracking_informations.class_code,' +
           'transcript_fpkm_tracking_informations.length,' +
           'transcript_fpkm_tracking_informations.coverage,' +
           'fpkm_samples.fpkm,' +
           'fpkm_samples.fpkm_lo,' +
           'fpkm_samples.fpkm_hi,' +
           'fpkm_samples.status, ' +
           'transcripts.name_from_program'
  end
  
  ###
  # Sets the available datasets that the user can query and which one of 
  # those datasets will be selected by default.
  def set_available_datasets_and_default_dataset()
    #Set available datasets
    @names_and_ids_for_available_datasets = []
    available_datasets = Dataset.where(:user_id => @current_user.id, 
                                       :has_transcript_isoforms => true,
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
  
  ###
  # Set any defaults related to the samples and sample comparisons.
  def set_sample_related_defaults()
    @available_samples = []
    @dataset.samples.sort.each do |sample|
      @available_samples << [sample.name, sample.id]
    end
    @sample_id = @available_samples.first[1] if @sample_id.blank?
    @sample_name = Sample.find_by_id(@sample_id).name
  end
  
  ###
  # Set any defaults related to sorting.
  def set_sort_defaults()
    super
    @available_sort_columns = ['Transcript','Associated Gene', 
                                'Class Code', 'Length','Coverage', 
                              'FPKM','FPKM Lower Bound','FPKM Upper Bound',
                              'Status']
    if @is_new_query == '1' or @sort_column.blank?
      @sort_column = @available_sort_columns.first 
    end
  end
  
  ###
  # Set defaults that do not fit into any other categories.
  def set_other_defaults()
    super
    @available_transcript_length_comparison_signs = 
        AVAILABLE_TRANSCRIPT_LENGTH_COMPARISON_SIGNS
    @transcript_length_value = '0' if @transcript_length_value.blank?
    if @transcript_length_comparison_sign.blank?
      @transcript_length_comparison_sign = '>='
    end
  end

  ###
  # Builds the select string to use for the query
  def build_select_string()
    select_string = 'transcripts.name_from_program as transcript_name, ' +
                    'genes.name_from_program as gene_name,' +
                    'transcript_fpkm_tracking_informations.class_code,' +
                    'transcript_fpkm_tracking_informations.length,' +
                    'transcript_fpkm_tracking_informations.coverage,' +
                    'fpkm_samples.fpkm,' +
                    'fpkm_samples.fpkm_lo,' +
                    'fpkm_samples.fpkm_hi,' +
                    'fpkm_samples.status'
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
  
  ###
  # Builds the ORDER BY string to use for the query
  def build_order_string()
    case @sort_column
    when'Transcript'
      sort_column = 'transcripts.name_from_program'
    when 'Associated Gene'
      sort_column = 'genes.name_from_program'
    when 'Class Code'
      sort_column = 'transcript_fpkm_tracking_informations.class_code'
    when 'Length'
      sort_column = 'transcript_fpkm_tracking_informations.length'
    when 'Coverage'
      sort_column = 'transcript_fpkm_tracking_informations.coverage'
    when 'FPKM'
      sort_column = 'fpkm_samples.fpkm'
    when 'FPKM Lower Bound'
      sort_column = 'fpkm_samples.fpkm_lo'
    when 'FPKM Upper Bound'
      sort_column = 'fpkm_samples.fpkm_hi'
    when 'Status'
      sort_column = 'fpkm_samples.status'
    end
    return "#{sort_column} #{@sort_order}"
  end
  
  ###
  # Generates the where clause(s) to user for the query
  def generate_where_clauses()
     #Create and run the query
    ds_t = Dataset.arel_table
    where_clauses = ds_t[:id].eq(@dataset_id)
    fs_t = FpkmSample.arel_table
    where_clauses = where_clauses.and(fs_t[:sample_id].eq(@sample_id))
    class_codes_where_clause = class_codes_where_clause()
    if not class_codes_where_clause.nil?
      where_clauses = where_clauses.and(class_codes_where_clause)
    end
    where_clauses = where_clauses.and(transcript_length_query_condition())
    if not @transcript_name.blank?
      tnqcg = TranscriptNameQueryConditionGenerator.new()
      tnqcg.name = @transcript_name
      where_clauses = where_clauses.and(tnqcg.generate_query_condition())
    end
    return where_clauses
  end
  
  ###
  # Runs the query in its paginated form. This is used when 
  # displaying the results to the user on the page.
  def execute_paged_query()
    if @has_go_terms == true
      @results = Dataset
        .joins(:transcripts => [:transcript_fpkm_tracking_information, 
                                :gene, :fpkm_samples])
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
      @results = Dataset
        .joins(:transcripts => [:transcript_fpkm_tracking_information, 
                                :gene, :fpkm_samples])
        .where(@where_clauses)
        .select(@select_string)
        .order(@order_string)
        .limit(self.class.page_size)
        .offset(self.class.page_size*(@page_number.to_i-1))
    end
  end
  
  ###
  # Runs the full query without pagination. This is used 
  # when emailing the results to the user as a text file.
  def execute_full_query()
    if @has_go_terms == true
      @results = Dataset
        .joins(:transcripts => [:transcript_fpkm_tracking_information, 
                                :gene, :fpkm_samples])
        .joins(self.class.thgt_left_join_string)
        .joins(self.class.go_terms_left_join_string)
        .where(@where_clauses)
        .group(self.class.group_by_string)
        .having(@having_string)
        .select(@select_string)
        .order(@order_string)
    else
      @results = Dataset
        .joins(:transcripts => [:transcript_fpkm_tracking_information, 
                                :gene, :fpkm_samples])
        .where(@where_clauses)
        .select(@select_string)
        .order(@order_string)
    end
  end
  
  ###
  # Counts the total number of records found in the query.
  def count_query_results()
    if @has_go_terms == true
      @results_count = Dataset
        .joins(:transcripts => [:transcript_fpkm_tracking_information, 
                                :gene, :fpkm_samples])
        .joins(self.class.thgt_left_join_string)
        .joins(self.class.go_terms_left_join_string)
        .where(@where_clauses)
        .group(self.class.group_by_string)
        .having(@having_string)
        .select('count(*)')
        .length
    else
      @results_count = Dataset
        .joins(:transcripts => [:transcript_fpkm_tracking_information, 
                                :gene, :fpkm_samples])
        .where(@where_clauses)
        .select('count(*) as count')[0]['count'].to_i
    end
  end
  
  private
  
  def class_codes_where_clause
    tfti_t = TranscriptFpkmTrackingInformation.arel_table
    tfti_w = nil
    CLASS_CODES.each do |key, value|
      if self.send(key) == '1'
        if tfti_w.nil?
          tfti_w = tfti_t[:class_code].eq(value)
        else
          tfti_w = tfti_w.or(tfti_t[:class_code].eq(value))
        end
      end
    end
    return tfti_w
  end
  
  def transcript_length_query_condition
    tfti_t = TranscriptFpkmTrackingInformation.arel_table
    case @transcript_length_comparison_sign
    when '>'
      tfti_w = tfti_t[:length].gt(@transcript_length_value)
    when '>='
      tfti_w = tfti_t[:length].gteq(@transcript_length_value)
    when '='
      tfti_w = tfti_t[:length].eq(@transcript_length_value)
    when '<'
      tfti_w = tfti_t[:length].lt(@transcript_length_value)
    when '=<'
      tfti_w = tfti_t[:length].lteq(@transcript_length_value)
    end
    return tfti_w
  end
end
