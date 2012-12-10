class Query_Diff_Exp_Transcripts
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :current_user, :dataset, :available_datasets, 
                :available_samples_for_comparison, :samples_to_compare,
                :sample_1, :sample_2,
                :fdr_or_pvalue, :cutoff, :filter_by_go_names, :go_names,
                :filter_by_go_ids, :go_ids, 
                :filter_by_transcript_length, 
                :transcript_length_comparison_sign, :transcript_length_value,
                :filter_by_transcript_name, :transcript_name, 
                :show_search_results, :search_results
  
  #For Boolean attributes, provide methods ending with a question mark 
  #  for convenience.
  def filter_by_go_names?
    return self.filter_by_go_names
  end
  def filter_by_go_ids?
    return self.filter_by_go_ids
  end
  def filter_by_transcript_length?
    return self.filter_by_transcript_length
  end
  def filter_by_transcript_name?
    return self.filter_by_transcript_name
  end
  def show_search_results?
    return self.show_search_results
  end
  
  #TODO: Add validation 
  validate :user_has_permission_to_access_dataset
  validate :sample_is_not_compared_against_itself
  
  def initialize(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    #TODO: Fix user setting
    self.current_user = User.first
    #Set available datasets
    self.available_datasets = []
    Dataset.find_all_by_user_id(current_user.id).each do |ds|
      self.available_datasets << [ds.name, ds.id]
    end
    #TODO: Set samples to compare
    #Set default values for the relavent blank attributes
    self.dataset = available_datasets.first if dataset.blank?
    self.fdr_or_pvalue = 'p_value' if fdr_or_pvalue.blank?
    self.cutoff = '0.05' if cutoff.blank?
    self.filter_by_go_names = false if filter_by_go_names.blank?
    self.filter_by_go_ids = false if filter_by_go_ids.blank?
    if filter_by_transcript_length.blank?
      self.filter_by_transcript_length = false
    end
    if self.transcript_length_comparison_sign.blank?
      self.transcript_length_comparison_sign = '>' 
    end
    self.transcript_length_value = '0' if transcript_length_value.blank?
    self.filter_by_transcript_name = false if filter_by_transcript_name.blank?
    #TODO: Set available samples for comparison
    self.available_samples_for_comparison = ['tom','dick','harry']
    self.sample_1 = self.available_samples_for_comparison[0]
    self.sample_2 = self.available_samples_for_comparison[1]
    Dataset.joins(:transcripts => :fpkm_samples).
    where(:id => dataset.id).select('sample_name, fpkm_samples.id')
  end
  
  def query()
    return if not self.valid?
    select_string = 'transcripts.name_from_program as transcript_name,' +
                    'genes.id as gene_id,' +
                    'differential_expression_tests.p_value,' +
                    'differential_expression_tests.fdr,' +
                    'differential_expression_tests.log_fold_change,' +
                    'differential_expression_tests.sample_1_id,' +
                    'differential_expression_tests.sample_2_id'
    query_results = 
      Dataset.joins(
        :transcripts => [:differential_expression_tests, :genes]
      ).
      where(
        'id' => current_user.id,
        'fpkm_samples.sample_name'=> [self.sample_1,self.sample_2]
      ).
      select(select_string)
    
                    
    search_results = []
    query_results.each do |query_result|
      gene = Gene.find_by_id(query_result.gene_id)
      sample_1_fpkm = FpkmSample.find_by_id(query_result.sample_1_id).fpkm
      sample_2_fpkm = FpkmSample.find_by_id(query_result.sample_1_id).fpkm
      search_result ={}
      search_result[:transcript_name] = query_result.name_from_program
      search_result[:gene_name] = gene.name_from_program
      search_result[:go_ids] = gene.go_terms.pluck('id')
      search_result[:p_value] = query_result.p_value
      search_result[:fdr] = query_result.fdr
      search_result[:sample_1] = self.sample_1
      search_result[:sample_2] = self.sample_2
      search_result[:sample_1_fpkm] = 
      search_result[:log_fold_change] = query_result.log_fold_change
      search_results << search_result
    end
  end
  
  def persisted?
      return false
  end
  
  private
  def user_has_permission_to_access_dataset
  end
end
