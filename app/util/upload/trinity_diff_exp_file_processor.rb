class TrinityDiffExpFileProcessor
  
  def initialize(uploaded_file, dataset)
    @uploaded_diff_exp_file = UploadedTrinityDiffExpFile.new(uploaded_file)
    @dataset = dataset
  end
  
  def process_file()
    create_sample_comparison()
  end
  
  protected
  
  def create_sample_comparison()
    (sample_1_name, sample_2_name) = @uploaded_diff_exp_file.sample_names
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
