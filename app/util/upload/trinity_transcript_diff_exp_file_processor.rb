require 'upload/trinity_diff_exp_file_processor.rb'

class TrinityTranscriptDiffExpFileProcessor < TrinityDiffExpFileProcessor
  def initialize(uploaded_file, dataset, sample_1_name, sample_2_name)
    super
    @sample_type = 'transcript'
  end
  
  def process_file()
    super
    while not @uploaded_diff_exp_file.eof?
      diff_exp_line = @uploaded_diff_exp_file.get_next_line
      next if diff_exp_line.nil?
      transcript = Transcript.where(:dataset_id => @dataset.id,
                                     :name_from_program => diff_exp_line.item).first
      if transcript.nil?
        #Find the associated gene if available
        gene_name = diff_exp_line.item.match(/\A(.+)(_seq.+)\z/).captures[0]
        gene = Gene.where(:dataset_id => @dataset.id,
                           :name_from_program => gene_name).first
        if gene.nil?
        gene = Gene.create!(:dataset => @dataset,
                            :name_from_program => gene_name)
        end	
        transcript =  Transcript.create!(:dataset => @dataset,
                                          :name_from_program => diff_exp_line.item,
                                          :gene => gene)
      end
      det = DifferentialExpressionTest.new()
      det.transcript = transcript
      det.sample_comparison = @sample_comparison
      det.log_fold_change = diff_exp_line.log_fold_change
      det.p_value = diff_exp_line.p_value
      det.fdr   = diff_exp_line.fdr
      det.save!
    end
  end
end
