class Query_Transcript_Isoforms
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id, :sample,
                :fdr_or_pvalue, :cutoff, :filter_by_class_codes,
                :class_code_equal, :class_code_c, :class_code_j, :class_code_e,
                :class_code_i, :class_code_o, :class_code_p, :class_code_r,
                :class_code_u, :class_code_x, :class_code_s, :class_code_dot,
                :filter_by_go_names, :go_names,
                :filter_by_go_ids, :go_ids, :filter_by_transcript_length, 
                :transcript_length_comparison_sign, :transcript_length_value,
                :filter_by_transcript_name, :transcript_name 
  attr_reader   :names_and_ids_for_available_datasets, 
                :available_samples_for_comparison, :available_class_codes,
                :show_results, :results, :fpkm_samples
  
  #For Boolean attributes, provide methods ending with a question mark 
  #  for convenience.
  def filter_by_class_codes?
    return @filter_by_class_codes
  end
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
    @show_results = false
  end
  
  def query!()
    #Don't query if it is not valid
    return if not self.valid?
    #Create and run the query
    select_string = 'transcripts.id as transcript_id,' +
                    'genes.name_from_program as gene_name,' +
                    'transcript_fpkm_tracking_informations.class_code,' +
                    'transcript_fpkm_tracking_informations.length,' +
                    'transcript_fpkm_tracking_informations.coverage,' +
                    'fpkm_samples.fpkm,' +
                    'fpkm_samples.fpkm_lo,' +
                    'fpkm_samples.fpkm_hi,' +
                    'fpkm_samples.status'
    query_results = 
      Dataset.joins(
        :transcripts => [:transcript_fpkm_tracking_information, :gene, :fpkm_samples]
      ).
      where(
        'datasets.id' => @dataset_id,
        'fpkm_samples.sample_name' => @sample
      ).
      select(select_string) 
    #Extract the query results to form that can be put in the view
    @results = []
    query_results.each do |query_result|
      #Do a few more minor queries to get the data in the needed format
      transcript = Transcript.find_by_id(query_result.transcript_id)
      #Fill in the result hash that the view will use to display the data
      result = {}
      result[:transcript_name] = transcript.name_from_program
      result[:gene_name] = query_result.gene_name
      result[:go_terms] = transcript.go_terms
      result[:class_code] = query_result.class_code
      result[:transcript_length] = query_result.length
      result[:coverage] = query_result.coverage
      result[:fpkm] = query_result.coverage
      result[:fpkm_lo] =  query_result.fpkm_lo
      result[:fpkm_hi] =  query_result.fpkm_hi
      result[:status] = query_result.status
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
