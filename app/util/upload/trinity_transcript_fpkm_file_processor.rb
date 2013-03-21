class TrinityTranscriptFpkmFileProcessor
  require 'upload/uploaded_trinity_fpkm_file.rb'

  def initialize(transcript_fpkm_file_path,dataset)
    @transcript_fpkm_file_path = transcript_fpkm_file_path
    @dataset = dataset
  end
  
  def process_file()
    trinity_fpkm_file = TrinityFpkmFile.new(@transcript_fpkm_file_path)
    while not trinity_fpkm_file.eof?
      fpkm_line = trinity_fpkm_line.get_next_line
      next if fpkm_line.nil?
      transcript = Transcript.where(:dataset => @dataset,
                                     :name_from_program => fpkm_line.item)[0]
      transcript.differential_expression_tests.each do |diff_exp_test|
        sample_1_name = diff_exp_test.sample_comparisons.sample_1.name
        sample_2_name = diff_exp_tests.sample_comparisons.sample_2.name
        fpkm_line.sample_fpkms do |sample_fpkm|
          if sample_fpkm.sample_name == sample_1_name
            diff_exp_test.sample_1_fpkm = sample_fpkm.fpkm
            diff_exp_test.save!
          else if sample_fpkm.sample_name == sample_2_name
            diff_exp_test.sample_2_fpkm = sample_fpkm.fpkm
            diff_exp_test.save!
          end
        end
      end
    end
    trinity_fpkm_file.close
  end  
end
