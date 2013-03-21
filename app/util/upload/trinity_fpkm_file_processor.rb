class TrinityFpkmFileProcessor
  require 'upload/uploaded_trinity_fpkm_file.rb'

  def initialize(uploaded_fpkm_file,dataset)
    @uploaded_fpkm_file = UploadedTrinityFpkmFile.new(uploaded_fpkm_file)
    @dataset = dataset
  end
  
  def process_file()
    raise NotImplementedError, 'Method must be implemented in child class'
  end
  
  protected 
  
  def set_fpkms_for_item(item,fpkm_line)
    item.differential_expression_tests.each do |diff_exp_test|
        sample_1_name = diff_exp_test.sample_comparison.sample_1.name
        sample_2_name = diff_exp_test.sample_comparison.sample_2.name
        fpkm_line.sample_fpkms.each do |sample_fpkm|
          if sample_fpkm.sample_name == sample_1_name
            diff_exp_test.sample_1_fpkm = sample_fpkm.fpkm
            diff_exp_test.save!
          elsif sample_fpkm.sample_name == sample_2_name
            diff_exp_test.sample_2_fpkm = sample_fpkm.fpkm
            diff_exp_test.save!
          end
        end
      end
  end
end
