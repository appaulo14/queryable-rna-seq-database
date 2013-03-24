require 'query/transcript_name_query_condition_generator.rb'
require 'query/go_ids_query_condition_generator.rb'
require 'query/go_terms_query_condition_generator.rb'

class QueryTranscriptIsoforms
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id, :sample_id,
                :class_code_equal, :class_code_c, :class_code_j, :class_code_e,
                :class_code_i, :class_code_o, :class_code_p, :class_code_r,
                :class_code_u, :class_code_x, :class_code_s, :class_code_dot,
                :go_terms,:go_ids,
                :transcript_length_comparison_sign, :transcript_length_value,
                :transcript_name 
  attr_reader  :names_and_ids_for_available_datasets, 
                :available_samples, :available_transcript_length_comparison_signs,
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
  
  def show_results?
    return @show_results
  end
  
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
    @available_transcript_length_comparison_signs =
      AVAILABLE_TRANSCRIPT_LENGTH_COMPARISON_SIGNS
    #Set default values for the relavent blank attributes
    @dataset_id = all_datasets_for_current_user.first.id if @dataset_id.blank?
    @transcript_length_value = '0' if transcript_length_value.blank?
    @transcript_length_comparison_sign = '>' if @transcript_length_comparison_sign.blank?
    #Set available samples for querying
    ds = Dataset.find_by_id(@dataset_id)
    @available_samples = []
    ds.samples.each do |sample|
      @available_samples << [sample.name, sample.id]
    end
    @sample_id = @available_samples[0][1] if @sample_id.blank?
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
    class_codes_where_clause = class_codes_where_clause()
    if not class_codes_where_clause.nil?
      where_clause = where_clause.and(class_codes_where_clause)
    end
    where_clause = where_clause.and(transcript_length_query_condition())
    if not @transcript_name.blank?
      tnqcg = TranscriptNameQueryConditionGenerator.new()
      tnqcg.name = @transcript_name
      where_clause = where_clause.and(tnqcg.generate_query_condition())
    end
    query_results = 
       Dataset.joins(
          :transcripts => [:transcript_fpkm_tracking_information, :gene, :fpkm_samples]
        ).where(where_clause).select(select_string)
    #Extract the query results to form that can be put in the view
    @sample_name = Sample.find_by_id(@sample_id).name
    @results = []
    query_results.each do |query_result|
      #Do a few more minor queries to get the data in the needed format
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
    else
      puts 'x'
      #???
    end
    return tfti_w
  end
end
