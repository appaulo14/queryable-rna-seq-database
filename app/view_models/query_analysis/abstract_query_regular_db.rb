require 'query/go_ids_query_condition_generator.rb'
require 'query/go_terms_query_condition_generator.rb'
require 'query/aggregate_string_generator.rb'

###
# Abstract view model for the view models of all the view models that query 
# the regular database, namely QueryDiffExpTranscripts, QueryDiffExpGenes, and 
# QueryTranscriptIsoforms.
#
# <b>Associated Controller:</b> QueryAnalysisController
#
# <b>Associated Worker:</b> WorkerForQueryRegularDb
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
  # The order in which to sort the query results
  attr_accessor :sort_order
  # The sort with which to sort the query results by
  attr_accessor :sort_column
  # Whether to display the query results on the web page or to send them to the 
  # user as a text file.
  attr_accessor :results_display_method
  # Whether this query is for a new query or if it is to change pages or 
  # re-sort an existing query.
  attr_accessor :is_new_query
  # The total number of records in the query results. 
  attr_accessor :results_count
  
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
  # Whether the results should be displayed to the user. This is only false 
  # when the user has not yet performed a query.
  attr_reader   :show_results
  # The available valid columns that the user can select to sort by
  attr_reader   :available_sort_columns
  # The available valid options for the sort order attribute. The keys show 
  # the display text and the values show the actual value.
  attr_reader   :available_sort_orders
  # The available page numbers that the user can go to, based on how many 
  # query results there are. 
  attr_reader   :available_page_numbers
  
  # The available valid options for the sort order attribute. The keys show 
  # the display text and the values show the actual value.
  AVAILABLE_SORT_ORDERS = {'ascending' => 'ASC', 'descending' => 'DESC'}
  
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true,
                         :numericality => {
                              :only_integer => true, 
                              :greater_than_or_equal => 0 
                          }
  
  validates :go_ids, :allow_blank => true,
                     :format => { :with => /\A\s*(GO:\d+;?\s*)+\z/ }
  
  validates :results_display_method, :presence => true,
                                     :inclusion => {:in => ['normal','email']}
  
  validates :page_number, :presence => true,
                          :numericality => {
                              :only_integer => true, 
                              :greater_than_or_equal => 0 
                          }
  validates :sort_order, :allow_blank => true,
                         :inclusion => {:in => AVAILABLE_SORT_ORDERS.values}
  
  validates :is_new_query, :presence => true,
                           :view_model_boolean => true
  validates :results_count, :allow_blank => true,
                            :numericality => {
                              :only_integer => true, 
                              :greater_than_or_equal => 0 
                            }
  
  ###
  # Abstract method that returns the type of query that the class provides
  def self.get_query_type()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  # Convenience method to see whether the query results should be displayed
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
    set_defaults_on_which_others_depend()
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
    begin
      record_that_dataset_has_been_queried()
      build_query_parts()
      if @results_display_method == 'email'
        execute_full_query()
        QueryAnalysisMailer.send_query_regular_db_results(self,@current_user)
      else
        execute_paged_query()
        if @is_new_query == '1'
          count_query_results()
          @is_new_query = '0'
        end
        if @results_count == 0
          @available_page_numbers = [1]
        else
          @available_page_numbers = (1..(@results_count.to_f/self.class.page_size.to_f).ceil).to_a
        end
        @show_results = true
      end
    rescue Exception => ex
      if @results_display_method == 'email'
        begin
          dataset = Dataset.find_by_id(@dataset_id)
          QueryAnalysisMailer.send_query_regular_db_failure_message(self,@current_user)
        rescue Exception => ex2
          Rails.logger.error "For dataset #{dataset.id} with name #{dataset.name}:\n" +
                            "#{ex2.message}\n#{ex2.backtrace.join("\n")}"
          raise ex2, ex2.message
        ensure
          #Log the exception manually because Rails doesn't want to in this case
          Rails.logger.error "For dataset #{dataset.id} with name #{dataset.name}:\n" +
                            "#{ex.message}\n#{ex.backtrace.join("\n")}"
        end
      else
        raise ex, "#{ex.message}\n#{ex.backtrace.join("\n")}"
      end
    end
  end
  
  ###
  # According to http://railscasts.com/episodes/219-active-model?view=asciicast,
  # this defines that this view model does not persist in the database.
  def persisted?
      return false
  end
  
  protected
  
  ###
  # Returns the string to use for the GROUP BY section of the query.
  # transcripts.id is at the end of the string to prevent a strange error 
  # with counting.
  def self.group_by_string
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  ###
  # Returns the join string to use when connecting the Transcript table to 
  # the TranscriptHasGoTerm table.
  def self.thgt_left_join_string
    return "LEFT OUTER JOIN transcript_has_go_terms " +
           "ON transcript_has_go_terms.transcript_id = transcripts.id"
  end
  
  ###
  # Returns the join string to use when connecting the TranscriptHasGoTerm 
  # table to the GoTerm table.
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
  
  ###
  # Sets defaults for attributes on which other attributes are derrived
  def set_defaults_on_which_others_depend()
    @is_new_query = '1' if @is_new_query.blank?
  end
  
  ###
  # Abstract method to set the available datasets that the user can query 
  # and which one of those datasets will be selected by default.
  def set_available_datasets_and_default_dataset()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  ###
  # Abstract method to set any defaults related to samples or sample 
  # comparisons.
  def set_sample_related_defaults()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  ###
  # Set any defaults related to sorting.
  def set_sort_defaults()
    @available_sort_orders = AVAILABLE_SORT_ORDERS
    if @is_new_query == '1' or @sort_order.blank?
      @sort_order = @available_sort_orders.values.first
    end
  end 
  
  ###
  # Set defaults that do not fit into any other categories.
  def set_other_defaults()
    @program_used = @dataset.program_used
    @has_go_terms = (@dataset.go_terms_status == 'found') ? true : false
    if @is_new_query == '1' or @page_number.blank? 
      @page_number = '1' 
    end
    @show_results = false if @show_results.blank?
    @results_display_method = 'normal' if @results_display_method.blank?
  end
  
  ###
  # Saves to the Dataset record that it has been queried just now. 
  def record_that_dataset_has_been_queried()
    @dataset.when_last_queried = Time.now
    @dataset.save!
  end
  
  ###
  # Abstract method to build the select string to use for the query
  def build_select_string()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  ### 
  # Abstract method to build the ORDER BY string to use for the query 
  def build_order_string()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  ###
  # Abstract method to generate the where clause(s) to use for the query
  def generate_where_clauses()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  ###
  # Generates the having clause(s) for the query
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
  
  ###
  # Build the different parts of the query
  def build_query_parts()
    @select_string = build_select_string()
    @where_clauses = generate_where_clauses()
    @having_string = generate_having_string()
    @order_string = build_order_string()
  end
  
  ###
  # Abstract method to run the query in its paginated form. This is used when 
  # displaying the results to the user on the page.
  def execute_paged_query()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  ###
  # Abstract method to run the full query without pagination. This is used 
  # when emailing the results to the user as a text file.
  def execute_full_query()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
  
  ###
  # Abstract method to count the total number of records found in the query
  def count_query_results()
    raise NotImplementedError, 'Must be implemented in subclass'
  end
end
