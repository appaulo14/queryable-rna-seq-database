require 'query/gene_name_query_condition_generator.rb'
require 'query/go_ids_query_condition_generator.rb'
require 'query/go_terms_query_condition_generator.rb'
require 'query/go_filter_checker.rb'

class QueryDiffExpGenes
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :dataset_id, :sample_comparison_id,
                :fdr_or_p_value, :cutoff, :go_terms, :go_ids, :gene_name,
                :piece
  attr_reader   :names_and_ids_for_available_datasets, 
                :available_sample_comparisons, 
                :show_results, :results, :sample_1_name, :sample_2_name,
                :program_used, :go_terms_status
  
  PIECE_SIZE = 100
  
  #TODO: Add validation 
  validate :user_has_permission_to_access_dataset
  validate :sample_is_not_compared_against_itself
  
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
    available_datasets = Dataset.where(:user_id => @current_user.id, 
                                       :has_gene_diff_exp => true,
                                       :finished_uploading => true)
                                .order(:name)
    available_datasets.each do |ds|
      @names_and_ids_for_available_datasets << [ds.name, ds.id]
    end
    #Set default values for the relavent blank attributes
    @dataset_id = available_datasets.first.id if @dataset_id.blank?
    @fdr_or_p_value = 'p_value' if fdr_or_p_value.blank?
    @cutoff = '0.05' if cutoff.blank?
    #Set available samples for comparison
    @available_sample_comparisons = []
    s_t = Sample.arel_table
    where_clause = s_t[:dataset_id].eq(@dataset_id)
    sample_type_eq_both = s_t[:sample_type].eq('both')
    sample_type_eq_gene = s_t[:sample_type].eq('gene')
    sample_type_where_clause = sample_type_eq_gene.or(sample_type_eq_both)
    where_clause = where_clause.and(sample_type_where_clause)
    sample_comparisons_query = SampleComparison.joins(:sample_1,:sample_2).
        where(where_clause).
        select('samples.name as sample_1_name, '+
               'sample_2s_sample_comparisons.name as sample_2_name, ' +
               'sample_comparisons.id as sample_comparison_id')
    sample_comparisons_query.each do |scq|
      display_text = "#{scq.sample_1_name} vs #{scq.sample_2_name}"
      value = scq.sample_comparison_id
      @available_sample_comparisons << [display_text, value]
    end
    @available_sample_comparisons.sort!{|t1,t2|t1[0] <=> t2[0]}
    if @sample_comparison_id.blank?
      @sample_comparison_id = @available_sample_comparisons[0][1]
    end
    sample_cmp = SampleComparison.find_by_id(@sample_comparison_id)
    @sample_1_name = sample_cmp.sample_1.name
    @sample_2_name = sample_cmp.sample_2.name
    @show_results = false
    dataset = Dataset.find_by_id(@dataset_id)
    @program_used = dataset.program_used
    @go_terms_status = dataset.go_terms_status
    @piece = '0' if @piece.blank?
  end
  
  def query()
    #Don't query if it is not valid
    return if not self.valid?
    #Record that the dataset was queried at this time
    @dataset = Dataset.find_by_id(@dataset_id)
    @dataset.when_last_queried = Time.now
    @dataset.save!
    #Retreive some variables to use later
    sample_comparison = SampleComparison.find_by_id(@sample_comparison_id)
    @sample_1_name = sample_comparison.sample_1.name
    @sample_2_name = sample_comparison.sample_2.name
    #Require parts of the where clause
    det_t = DifferentialExpressionTest.arel_table
    where_clause = det_t[:sample_comparison_id].eq(sample_comparison.id)
    #where_clause = where_clause.and(sample_cmp_clause)
    if @fdr_or_p_value == 'p_value'
      where_clause = where_clause.and(det_t[:p_value].lteq(@cutoff))
    else
      where_clause = where_clause.and(det_t[:fdr].lteq(@cutoff))
    end
    #Optional parts of the where clause
    if not @gene_name.blank?
      gnqcg = GeneNameQueryConditionGenerator.new()
      gnqcg.name = @gene_name
      where_clause = where_clause.and(gnqcg.generate_query_condition())
    end
    query_results = 
      DifferentialExpressionTest.joins(:gene)
                                .where(where_clause)
                                .limit(PIECE_SIZE)
                                .offset(PIECE_SIZE*@piece.to_i)
    #Extract the query results to form that can be put in the view
    @results = []
    query_results.each do |query_result|
      #Do a few more minor queries to get the data in the needed format
      gene = Gene.find_by_id(query_result.gene_id)
      transcripts = gene.transcripts
      if (@dataset.go_terms_status == 'found' and (not @go_ids.blank? or not @go_terms.blank?))
        match_found = false
        transcripts.each do |transcript|
          go_filter_checker = GoFilterChecker.new(transcript.id,@go_ids,@go_terms)
          if go_filter_checker.passes_go_filters() == true
            match_found = true
            break
          end
        end
        next if not match_found
      end
      #Fill in the result hash that the view will use to display the data
      result = {}
      result[:gene_name] = gene.name_from_program #det.gene
      result[:transcript_names] = transcripts.map{|t| t.name_from_program} #det.gene.transcript_names
      if (@dataset.go_terms_status == 'found')
        result[:go_terms] = transcripts.map{|t| t.go_terms}.flatten.uniq{|g| g.id}
      else
        result[:go_terms] = []
      end
      result[:test_statistic] = query_result.test_statistic
      result[:p_value] = query_result.p_value
      result[:fdr] = query_result.fdr
      result[:sample_1_fpkm] =  query_result.sample_1_fpkm
      result[:sample_2_fpkm] =  query_result.sample_2_fpkm
      result[:log_fold_change] = query_result.log_fold_change
      result[:test_status] = query_result.test_status
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
