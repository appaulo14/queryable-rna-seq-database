Factory.define :job do |job|
#   job.association       :gene
#   job.association       :transcript
end

# Factor.define :test_status do |test_status|
#     test_status.name = "OK"
#     test_status.description = "The ran successfully."
#     test_status.association :differential_expression_test
# end

Factory.define :differential_expression_test do |differential_expression_test|
  #differential_expression_test.association      :gene
  #differential_expression_test.association      :transcript
  
  differential_expression_test.sample1          "Sample 1 Name"
  differential_expression_test.sample2          "Sample 2 Name"
  differential_expression_test.test_status_name "OK"
  differential_expression_test.fpkm_x            1.1243
  differential_expression_test.fpkm_y            4343.2
  differential_expression_test.log2_y_over_x    332.11
  differential_expression_test.test_stat        0.0001
  differential_expression_test.p_value          0.05
  differential_expression_test.q_value          0.0005
  differential_expression_test.is_significant   true
end

Factory.define :gene do |gene|
  gene.name_from_program        "XLOC_00001"
  #gene.association              :transcript
  gene.association              :job
  gene.association              :differential_expression_test
end

Factory.define :transcript do |transcript|
  transcript.name_from_program        "TCONS_00001"
  transcript.sequence                 "ATKMBVCNSWD-GUYRHatkmbvcnswd-guyrh"
  transcript.association              :gene
  transcript.association              :job
  transcript.association               :differential_expression_test
end

Factory.define :fpkm_sample do |fpkm_sample|
    fpkm_sample.sample_number           1
    fpkm_sample.q_FPKM                  2.22
    fpkm_sample.q_FPKM_hi               33.33
    fpkm_sample.q_FPKM_lo               0.05
    fpkm_sample.q_status                "OK"
    fpkm_sample.association     :transcript
end