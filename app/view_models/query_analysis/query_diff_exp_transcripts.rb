class Query_Diff_Exp_Transcripts
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset, :available_datasets, 
                :available_samples_for_comparison, :samples_to_compare, 
                :fdr_or_pvalue, :cutoff, :filter_by_go_names, :go_names,
                :filter_by_go_ids, :go_ids, 
                :filter_by_transcript_length, 
                :transcript_length_comparison_sign, :transcript_length_value,
                :filter_by_transcript_name, :transcript_name, :search_results
  
  #TODO: Add validation 
  validate :user_has_permission_to_access_dataset
  
  def initialize(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    #Set available datasets
    available_datasets = Dataset.find_by_user_id(current_user.id)
    #TODO: Set available samples for comparison
    #TODO: Set samples to compare
    #Set default values for the relavent blank attributes
    dataset = available_datasets.first if dataset.blank?
    available_samples_for_comparison = dataset
    fdr_or_pvalue = 'fdr' if fdr_or_pvalue.blank?
    cutoff = '0.05' if cutoff.blank?
    filter_by_go_names = false if filter_by_go_names.blank?
    filter_by_go_ids = false if filter_by_go_ids.blank?
    filter_by_go_ids = false if filter_by_go_ids.blank?
    filter_by_transcript_length = false if filter_by_transcript_length.blank?
    if transcript_length_comparison_sign.blank?
      transcript_length_comparison_sign = '>' 
    end
    transcript_length_value = '0' if transcript_length_value.blank?
    filter_by_transcript_name = false if filter_by_transcript_name.blank?
  end
  
  def persisted?
      return false
  end
  
  private
  def user_has_permission_to_access_dataset
  end
end
