require 'upload/uploaded_trinity_fpkm_file.rb'

###
# Abstract Utility class for processing trinity fpkm files
class TrinityFpkmFileProcessor
  
  ###
  # parameters::
  # * <b>uploaded_file:</b> The uploaded file to process
  # * <b>dataset:</b> The dataset for this upload operation
  def initialize(uploaded_fpkm_file,dataset)
    @uploaded_fpkm_file = UploadedTrinityFpkmFile.new(uploaded_fpkm_file)
    @dataset = dataset
  end
  
  ###
  # Do the actual processing of the fpkm file. This method needs to be 
  # implemented in the subclass.
  def process_file()
    raise NotImplementedError, 'Method must be implemented in child class'
  end
  
  protected 
  
  ###
  # Takes a Gene or Transcript and a TrinityFpkmLine and puts the fpkm values 
  # from the TrinityFpkmLine into the proper DifferentialExpressionTest records.
  def set_fpkms_for_item(item,fpkm_line)
    item.differential_expression_tests.each do |diff_exp_test|
      #Add any FPKMs for this item
      sample_1_name = diff_exp_test.sample_comparison.sample_1.name
      sample_2_name = diff_exp_test.sample_comparison.sample_2.name
      fpkm_line.sample_fpkms.each do |sample_fpkm|
        if sample_fpkm.sample_name.match(/#{sample_1_name}/i)
          diff_exp_test.sample_1_fpkm = sample_fpkm.fpkm
          diff_exp_test.save!
        elsif sample_fpkm.sample_name.match(/#{sample_2_name}/i)
          diff_exp_test.sample_2_fpkm = sample_fpkm.fpkm
          diff_exp_test.save!
        end
      end
    end
    #Ensure that all the item's differential_expression_tests have fpkms now
    item.differential_expression_tests.each do |diff_exp_test|
      if diff_exp_test.sample_1_fpkm.nil? or diff_exp_test.sample_2_fpkm.nil?
        error_msg = "Dataset #{@dataset.id}, #{@dataset.name} "
        error_msg += "#{item.class.to_s} #{item.name_from_program} "
        error_msg += "is missing require values "
        missing = []
        if diff_exp_test.sample_1_fpkm.nil?
          missing << "fpkm 1"
        end
        if diff_exp_test.sample_1_fpkm.nil?
          missing << "fpkm 2"
        end
        error_msg += missing.to_s
        raise StandardError, error_msg
      end
    end
  end
end
