class QueryTranscriptIsoforms
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id, :sample_id,
                :filter_by_class_codes,
                :class_code_equal, :class_code_c, :class_code_j, :class_code_e,
                :class_code_i, :class_code_o, :class_code_p, :class_code_r,
                :class_code_u, :class_code_x, :class_code_s, :class_code_dot,
                :filter_by_go_terms, :go_terms,
                :filter_by_go_ids, :go_ids, :filter_by_transcript_length, 
                :transcript_length_comparison_sign, :transcript_length_value,
                :filter_by_transcript_name, :transcript_name 
  attr_reader  :names_and_ids_for_available_datasets, 
                :available_samples,
                :show_results, :results, :sample_name
  
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
  
  def show_results?
    return @show_results
  end
  
  #TODO: Add validation 
  validate :user_has_permission_to_access_dataset
  #validate if filter box is checked then some options are selected
  
  def initialize(current_user)
    @current_user = current_user
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
    @filter_by_go_terms = false if filter_by_go_terms.blank?
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
    ds = Dataset.find_by_id(@dataset_id)
    @available_samples = []
    ds.samples.each do |sample|
      @available_samples << [sample.name, sample.id]
    end
    @sample_id = @available_samples[0][1]
    @show_results = false
  end
  
  def query()
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
    ds_t = Dataset.arel_table
    where_clause = ds_t[:id].eq(@dataset_id)
    fs_t = FpkmSample.arel_table
    where_clause = where_clause.and(fs_t[:sample_id].eq(@sample_id))
    if @filter_by_class_codes == '1'
      where_clause = where_clause.and(generate_class_codes_where_clause())
    end
    if @filter_by_transcript_length == '1'
      where_clause = where_clause.and(generate_transcript_length_where_clause())
    end
    if @filter_by_transcript_name == '1'
      where_clause = where_clause.and(generate_transcript_name_where_clause())
    end
    query_results = 
     Dataset.joins(
        :transcripts => [:transcript_fpkm_tracking_information, :gene, :fpkm_samples]
      ).
      where(where_clause).select(select_string)
    #Extract the query results to form that can be put in the view
    @sample_name = Sample.find_by_id(@sample_id).name
    @results = []
    query_results.each do |query_result|
      #Do a few more minor queries to get the data in the needed format
      transcript = Transcript.find_by_id(query_result.transcript_id)
      if @filter_by_go_ids == '1'
        next if (transcript.go_terms & GoTerm.where(generate_go_ids_where_clause())).empty?
      end
      if @filter_by_go_terms == '1'
        next if (transcript.go_terms & GoTerm.where(generate_go_terms_where_clause())).empty?
      end
      #Fill in the result hash that the view will use to display the data
      result = {}
      result[:transcript_name] = transcript.name_from_program
      result[:gene_name] = query_result.gene_name
      result[:go_terms] = transcript.go_terms
      result[:class_code] = query_result.class_code
      result[:transcript_length] = query_result.length
      result[:coverage] = query_result.coverage
      result[:fpkm] = query_result.fpkm
      result[:fpkm_lo] =  query_result.fpkm_lo
      result[:fpkm_hi] =  query_result.fpkm_hi
      result[:status] = query_result.status
      @results << result
    end
    #Mark the search results as viewable
    @show_results = true
  end
  
  #According http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
  
  private
  def generate_class_codes_where_clause
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
  
  def generate_go_ids_where_clause
    go_terms = @go_ids.split(';')
    gt_t = GoTerm.arel_table
    where_clauses = []
    go_terms.each do |go_term|
      where_clauses << gt_t[:id].eq(go_term.strip)
    end
    if where_clauses.count > 1
      combined_where_clause = where_clauses[0]
      (1..where_clauses.count-1).each do |i|
        combined_where_clause = combined_where_clause.or(where_clauses[i])
      end
      return combined_where_clause
    else
      return where_clauses[0]
    end
  end
  
  def generate_go_terms_where_clause
    go_terms = @go_terms.split(';')
    gt_t = GoTerm.arel_table
    where_clauses = []
    go_terms.each do |go_term|
      where_clauses << gt_t[:term].matches("%#{go_term.strip}%")
    end
    if where_clauses.count > 1
      combined_where_clause = where_clauses[0]
      (1..where_clauses.count-1).each do |i|
        combined_where_clause = combined_where_clause.or(where_clauses[i])
      end
      return combined_where_clause
    else
      return where_clauses[0]
    end
  end
  
  def generate_transcript_name_where_clause
    t_t = Transcript.arel_table
    return t_t[:name_from_program].eq(@transcript_name)
  end
  
  def generate_transcript_length_where_clause
    tfti_t = TranscriptFpkmTrackingInformation.arel_table
    case transcript_length_comparison_sign
    when '>'
      tfti_w = tfti_t[:length].gt(@transcript_length_value)
    when '>='
      tfti_w = tfti_t[:length].gte(@transcript_length_value)
    when '='
      tfti_w = tfti_t[:length].eq(@transcript_length_value)
    when '<'
      tfti_w = tfti_t[:length].lt(@transcript_length_value)
    when '=<'
      tfti_w = tfti_t[:length].lte(@transcript_length_value)
    else
      puts 'x'
      #???
    end
    return tfti_w
  end
  
  def user_has_permission_to_access_dataset
  end
  
  def sample_is_not_compared_against_itself
  end
end
