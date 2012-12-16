class Query_Diff_Exp_Transcripts
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id, :samples_to_compare, :sample_1, :sample_2,
                :fdr_or_pvalue, :cutoff, :filter_by_go_names, :go_names,
                :filter_by_go_ids, :go_ids, :filter_by_transcript_length, 
                :transcript_length_comparison_sign, :transcript_length_value,
                :filter_by_transcript_name, :transcript_name 
  attr_reader   :names_and_ids_for_available_datasets, 
                :available_samples_for_comparison, 
                :show_results, :results
  
  #For Boolean attributes, provide methods ending with a question mark 
  #  for convenience.
  def filter_by_go_names?
    return @filter_by_go_names
  end
  def filter_by_go_ids?
    return @filter_by_go_ids
  end
  def filter_by_transcript_length?
    return @filter_by_transcript_length
  end
  def filter_by_transcript_name?
    return @filter_by_transcript_name
  end
  def show_results?
    return @show_results
  end
  
  #TODO: Add validation 
  validate :user_has_permission_to_access_dataset
  validate :sample_is_not_compared_against_itself
  
  def initialize(user)
    @current_user = user
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
    @fdr_or_pvalue = 'p_value' if fdr_or_pvalue.blank?
    @cutoff = '0.05' if cutoff.blank?
    @filter_by_go_names = false if filter_by_go_names.blank?
    @filter_by_go_ids = false if filter_by_go_ids.blank?
    if filter_by_transcript_length.blank?
      @filter_by_transcript_length = false
    end
    if @transcript_length_comparison_sign.blank?
      @transcript_length_comparison_sign = '>' 
    end
    @transcript_length_value = '0' if transcript_length_value.blank?
    @filter_by_transcript_name = false if filter_by_transcript_name.blank?
    #Set available samples for comparison
    @available_samples_for_comparison = 
        Dataset.joins(:transcripts => :fpkm_samples).
        where(:id => @dataset_id).pluck('fpkm_samples.sample_name').uniq
    @sample_1 = @available_samples_for_comparison[0]
    @sample_2 = @available_samples_for_comparison[1]
    @show_results = false
  end
  
  def query!()
    #Don't query if it is not valid
    return if not self.valid?
    #Create and run the query
    select_string = 'transcripts.id as transcript_id,' +
                    'genes.name_from_program as gene_name,' +
                    'differential_expression_tests.p_value,' +
                    'differential_expression_tests.fdr,' +
                    'differential_expression_tests.log_fold_change as logfc,' +
                    'differential_expression_tests.fpkm_sample_1_id,' +
                    'differential_expression_tests.fpkm_sample_2_id '
    query_results = 
      Dataset.joins(
        :transcripts => [:differential_expression_tests, :gene, :fpkm_samples]
      ).
      where(
        'datasets.id' => @dataset_id,
        'fpkm_samples.sample_name' => [@sample_1,@sample_2]
      ).
      select(select_string) 
    #Extra the query results to form that can be put in the view
    @results = []
    query_results.each do |query_result|
      transcript = Transcript.find_by_id(query_result.transcript_id)
      sample_1_fpkm = FpkmSample.find_by_id(query_result.fpkm_sample_1_id).fpkm
      sample_2_fpkm = FpkmSample.find_by_id(query_result.fpkm_sample_1_id).fpkm
      result = {}
      result[:transcript_name] = transcript.name_from_program
      result[:gene_name] = query_result.gene_name
      result[:go_terms] = transcript.go_terms
      result[:p_value] = query_result.p_value
      result[:fdr] = query_result.fdr
      result[:sample_1_name] = @sample_1
      result[:sample_2_name] = @sample_2
      result[:sample_1_fpkm] =  sample_1_fpkm
      result[:sample_2_fpkm] =  sample_2_fpkm
      result[:log_fold_change] = query_result.logfc
      @results << result
    end
    #Mark the search results as viewable
    @show_results = true
  end
  
  def persisted?
      return false
  end
  
  private
  def user_has_permission_to_access_dataset
  end
  
  def sample_is_not_compared_against_itself
  end
end
