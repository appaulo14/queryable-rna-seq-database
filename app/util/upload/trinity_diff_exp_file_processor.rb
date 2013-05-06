require 'upload/uploaded_trinity_diff_exp_file.rb'

###
# Abstract utility class for processing trinity differential expression files
class TrinityDiffExpFileProcessor
  
  ###
  # parameters::
  # * <b>uploaded_file:</b> The uploaded file to process
  # * <b>dataset:</b> The dataset for this upload operation
  # * <b>sample_1_name:</b> The name of the first sample in the differential 
  #   expression file.
  # * <b>sample_2_name:</b> The name of the second sample in the differential 
  #   expression file.
  def initialize(uploaded_file, dataset,sample_1_name, sample_2_name)
    @uploaded_diff_exp_file = UploadedTrinityDiffExpFile.new(uploaded_file)
    @sample_1_name = sample_1_name
    @sample_2_name = sample_2_name
    @dataset = dataset
    @sample_type = nil #this should be defined the sublcass
  end
  
  ###
  # Do the actual processing of the differential expression file. This method 
  # is only partially implemented here. The rest needs to be implemented in the 
  # subclass.
  def process_file()
    create_sample_comparison()
  end
  
  protected
  
  ###
  # Creates the Sample and SampleComparison records from this differential 
  # expression file if they don't already exist.
  def create_sample_comparison()
    sample_1 = Sample.where(:name => @sample_1_name,
                             :dataset_id => @dataset.id,
                             :sample_type => @sample_type).first
    if sample_1.nil?
      sample_1 = Sample.create!(:name => @sample_1_name,
                                :dataset => @dataset,
                                :sample_type => @sample_type)
    end
    sample_2 = Sample.where(:name => @sample_2_name,
                             :dataset_id => @dataset.id,
                             :sample_type => @sample_type).first
    if sample_2.nil?
      sample_2 = Sample.create!(:name => @sample_2_name,
                                 :dataset => @dataset,
                                 :sample_type => @sample_type)
    end
    @sample_comparison = SampleComparison.where(:sample_1_id => sample_1.id,
                                                :sample_2_id => sample_2.id).first
    if @sample_comparison.nil?
      @sample_comparison = SampleComparison.create!(:sample_1 => sample_1,
                                                     :sample_2 => sample_2)
    end
  end
end
