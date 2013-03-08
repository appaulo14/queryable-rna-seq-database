class QueryDiffExpGenes
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id, :sample_comparison_id_pair,
                :fdr_or_p_value, :cutoff, :filter_by_go_names, :go_names,
                :filter_by_go_ids, :go_ids,  
                :filter_by_gene_name, :gene_name 
  attr_reader   :names_and_ids_for_available_datasets, 
                :available_sample_comparisons, 
                :show_results, :results, :sample_1_name, :sample_2_name
  
  #For Boolean attributes, provide methods ending with a question mark 
  #  for convenience.
  def filter_by_go_names?
    return @filter_by_go_names
  end
  def filter_by_go_ids?
    return @filter_by_go_ids
  end
  def filter_by_gene_name?
    return @filter_by_gene_name
  end
  def show_results?
    return @show_results
  end
  
  #TODO: Add validation 
  validate :user_has_permission_to_access_dataset
  validate :sample_is_not_compared_against_itself
  
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
    @fdr_or_p_value = 'p_value' if fdr_or_p_value.blank?
    @cutoff = '0.05' if cutoff.blank?
    @filter_by_go_names = false if filter_by_go_names.blank?
    @filter_by_go_ids = false if filter_by_go_ids.blank?
    @filter_by_gene_name = false if filter_by_gene_name.blank?
    #Set available samples for comparison
    @available_sample_comparisons = []
    sample_comparisons_query = SampleComparison.joins(:sample_1,:sample_2).
        where('samples.dataset_id' => @dataset_id).
        select('samples.name as sample_1_name, '+
               'sample_2s_sample_comparisons.name as sample_2_name, ' +
               'samples.id as sample_1_id, ' +
               'sample_2s_sample_comparisons.id as sample_2_id')
    sample_comparisons_query.each do |scq|
      display_text = "#{scq.sample_1_name} vs #{scq.sample_2_name}"
      value = "#{scq.sample_1_id},#{scq.sample_2_id}"
      @available_sample_comparisons << [display_text, value]
    end
    @sample_comparison_id_pair = @available_sample_comparisons[0][1]
    @show_results = false
  end
  
  def query!()
    #Don't query if it is not valid
    return if not self.valid?
    #Create and run the query
#     select_string = 'genes.id as gene_id,' +
#                     'differential_expression_tests.p_value,' +
#                     'differential_expression_tests.fdr,' +
#                     'differential_expression_tests.log_fold_change as logfc,' +
#                     'differential_expression_tests.fpkm_sample_1_id,' +
#                     'differential_expression_tests.fpkm_sample_2_id '
#     query_results = 
#       Dataset.joins(
#         :genes => [:differential_expression_test, :fpkm_samples]
#       ).
#       where(
#         'datasets.id' => @dataset_id,
#         'fpkm_samples.sample_name' => [@sample_1,@sample_2]
#       ).
#       select(select_string) 
    sample_ids = @sample_comparison_id_pair.split(',')
    sample_1 = Sample.find_by_id(sample_ids[0])
    sample_2 = Sample.find_by_id(sample_ids[1])
    query_results = DifferentialExpressionTest.joins(
        [:fpkm_sample_1,:fpkm_sample_2]
      ).
      where('fpkm_samples.sample_id' => sample_1.id,
        'fpkm_sample_2s_differential_expression_tests.sample_id' => sample_2.id,
        'differential_expression_tests.transcript_id' => nil
      ).
      select(
        'differential_expression_tests.gene_id, ' +
        'differential_expression_tests.p_value, ' +
        'differential_expression_tests.fdr, ' +
        'differential_expression_tests.log_fold_change, ' +
        'fpkm_samples.fpkm as sample_1_fpkm, ' +
        'fpkm_sample_2s_differential_expression_tests.fpkm as sample_2_fpkm'
      )
    #Extract the query results to form that can be put in the view
    @sample_1_name = sample_1.name
    @sample_2_name = sample_2.name
    @results = []
    query_results.each do |query_result|
      #Do a few more minor queries to get the data in the needed format
      gene = Gene.find_by_id(query_result.gene_id)
      transcripts = gene.transcripts
      #Fill in the result hash that the view will use to display the data
      result = {}
      result[:gene_name] = gene.name_from_program #det.gene
      result[:transcript_names] = transcripts.map{|t| t.name_from_program} #det.gene.transcript_names
      result[:go_terms] = transcripts.map{|t| t.go_terms}.flatten
      result[:p_value] = query_result.p_value
      result[:fdr] = query_result.fdr
      result[:sample_1_fpkm] =  query_result.sample_1_fpkm
      result[:sample_2_fpkm] =  query_result.sample_2_fpkm
      result[:log_fold_change] = query_result.log_fold_change
      @results << result
    end
    #Mark the search results as viewable
    @show_results = true
  end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
  
  private
  def user_has_permission_to_access_dataset
  end
  
  def sample_is_not_compared_against_itself
  end
end
