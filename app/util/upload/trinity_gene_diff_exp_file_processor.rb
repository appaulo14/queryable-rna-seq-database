require 'upload/trinity_diff_exp_file_processor.rb'

class TrinityGeneDiffExpFileProcessor < TrinityDiffExpFileProcessor
  
  def process_file()
    super
    while not @uploaded_diff_exp_file.eof?
      diff_exp_line = @uploaded_diff_exp_file.get_next_line
      gene = Gene.where(:dataset_id => @dataset.id,
                         :name_from_program => diff_exp_line.item)[0]
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
