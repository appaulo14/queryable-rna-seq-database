class TrinityTranscriptDiffExpFileProcessor < TrinityDiffExpFileProcessor
  def process_file()
    super
    while not @uploaded_diff_exp_file .eof?
      diff_exp_line = @uploaded_diff_exp_file.get_next_line
      next if diff_exp_line.nil?
      transcript = Transcript.where(:dataset_id => @dataset.id,
                                     :name_from_program => diff_exp_line.item)[0]
      if transcript.nil?
        transcript =  Transcript.create!(:dataset => @dataset,
                                          :name_from_program => diff_exp_line.item)
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
