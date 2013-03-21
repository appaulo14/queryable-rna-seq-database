class TrinityGeneDiffExpFileProcessor < TrinityDiffExpFileProcessor
  
  def initialize(uploaded_file, dataset)
    @uploaded_file = uploaded_file
    @dataset = dataset
  end
  
  def process_file()
    super
    diff_exp_file = UploadedTrinityDiffExpFile.new(@uploaded_file)
    create_sample_comparison(diff_exp_file)
    while not diff_exp_file.eof?
      diff_exp_line = diff_exp_file.get_next_line
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
      det.fdr	= diff_exp_line.fdr
      det.save!
    end
  end
  
  protected
  
  def create_sample_comparison(diff_exp_file)
    (sample_1_name, sample_2_name) = diff_exp_file.sample_names
    sample_1 = Sample.where(:name => sample_1_name,
                             :dataset_id => @dataset.id)[0]
    if sample_1.nil?
      sample_1 = Sample.create!(:name => sample_1_name,
                               :dataset => @dataset)
    end
    sample_2 = Sample.where(:name => sample_2_name,
                             :dataset_id => @dataset.id)[0]
    if sample_2.nil?
      sample_2 = Sample.create!(:name => sample_2_name,
                                 :dataset => @dataset)
    end
    @sample_comparison = SampleComparison.where(:sample_1_id => sample_1.id,
                                                 :sample_2_id => sample_2.id)[0]
    if @sample_comparison.nil?
      @sample_comparison = SampleComparison.create!(:sample_1 => sample_1,
                                                     :sample_2 => sample_2)
    end
  end
end
