require 'query/go_ids_query_condition_generator.rb'
require 'query/go_terms_query_condition_generator.rb'
require 'query/aggregate_string_generator.rb'

class AbstractQueryRegularDb
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  # The id of the dataset whose transcript differential expression tests will be 
  # queried.
  attr_accessor :dataset_id
  # Specifies that only the differential expression tests with transcripts that 
  # have all of these go terms (names) should be displayed in the 
  # query results.
  attr_accessor :go_terms
  # Specifies that only the differential expression tests with transcripts that 
  # have all of these go ids (accessions) should be displayed in the 
  # query results.
  attr_accessor :go_ids
  # Because the query results are loaded in pieces using LIMIT and OFFSET, 
  # this specifies which piece to load.
  attr_accessor :page_number
  attr_accessor :sort_order
  attr_accessor :sort_column
  
  # The name/id pairs of the datasets that can be selected to have their 
  # transcript differential expression tests queried.
  attr_reader   :names_and_ids_for_available_datasets
  # Contains the results from the query
  attr_reader   :results
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
  
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true,
                         :numericality => {
                              :only_integer => true, 
                              :greater_than_or_equal => 0 
                          }
  
  AVAILABLE_SORT_ORDERS = {'ascending' => 'ASC', 'descending' => 'DESC'}
  
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
  
  protected
  
  ###
  # The string to use for the GROUP BY section of the query.
  # transcripts.id is at the end of the string to prevent a strange error 
  # with counting
  def self.group_by_string
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  def self.thgt_left_join_string
    return "LEFT OUTER JOIN transcript_has_go_terms " +
           "ON transcript_has_go_terms.transcript_id = transcripts.id"
  end
  
  def self.go_terms_left_join_string
    return "LEFT OUTER JOIN go_terms " +
           "ON transcript_has_go_terms.go_term_id = go_terms.id"
  end
  
  ###
  # The number of records in each piece of the query. This is used to 
  # determine the values for LIMIT and OFFSET in the query itself.
  def self.page_size
    return 50
  end
  
  def set_available_datasets_and_default_dataset()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  def set_sample_related_defaults()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  def set_sort_defaults()
    raise NotImplementedError, 'Must be implemented in subclass'
  end 
  
  def set_other_defaults()
    @program_used = @dataset.program_used
    @has_go_terms = (@dataset.go_terms_status == 'found') ? true : false
    @page_number = '1' if @page_number.blank?
    @show_results = false if @show_results.blank?
  end
  
  def record_that_dataset_has_been_queried()
    @dataset.when_last_queried = Time.now
    @dataset.save!
  end
  
  def build_select_string()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  def build_order_string()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  def generate_where_clauses()
    raise NotImplementedError, 'Must be implemented in subclass'
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
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  def count_query_results()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
end
