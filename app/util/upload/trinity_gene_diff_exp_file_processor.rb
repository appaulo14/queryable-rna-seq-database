require 'upload/trinity_diff_exp_file_processor.rb'

###
# Utility class for processing trinity gene differential expression files
class TrinityGeneDiffExpFileProcessor < TrinityDiffExpFileProcessor
  ###
  # parameters::
  # * <b>uploaded_file:</b> The uploaded file to process
  # * <b>dataset:</b> The dataset for this upload operation
  # * <b>sample_1_name:</b> The name of the first sample in the differential 
  #   expression file.
  # * <b>sample_2_name:</b> The name of the second sample in the differential 
  #   expression file.
  def initialize(uploaded_file, dataset, sample_1_name, sample_2_name)
    super
    @sample_type = 'gene'
  end
  
  ###
  # Do the actual processing of the gene differential expression file, 
  # writing the records to the database.
  def process_file()
    super
    while not @uploaded_diff_exp_file.eof?
      diff_exp_line = @uploaded_diff_exp_file.get_next_line
      gene = Gene.where(:dataset_id => @dataset.id,
                         :name_from_program => diff_exp_line.item).first
      if gene.nil?
        gene =  Gene.create!(:dataset => @dataset,
                             :name_from_program => diff_exp_line.item)
      end
      det = DifferentialExpressionTest.new()
      det.gene = gene
      det.sample_comparison = @sample_comparison
      det.log_fold_change = diff_exp_line.log_fold_change
      det.p_value = diff_exp_line.p_value
      det.fdr   = diff_exp_line.fdr
      det.save!
    end
  end
end
