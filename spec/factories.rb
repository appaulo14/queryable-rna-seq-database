FactoryGirl.define do
    factory :job do
        eid_of_owner    'nietz111@ksu.edu'
    end
    
    factory :differential_expression_test do
        sample1          'Sample 1 Name'
        sample2          'Sample 2 Name'
        test_status_name 'OK'
        fpkm_x            1.1243
        fpkm_y            4343.2
        log2_y_over_x    332.11
        test_stat        0.0001
        p_value          0.05
        q_value          0.0005
        is_significant   true
    end
    
    factory :gene do
        name_from_program        'XLOC_00001'
        association              :job
        association              :differential_expression_test
    end
    
    factory :transcript do
        name_from_program        'TCONS_00001'
        fasta_sequence           'ATKMBVCNSWD-GUYRHatkmbvcnswd-guyrh'
        association              :gene
        association              :job
        association              :differential_expression_test
    end
    
    factory :fpkm_sample do
        sample_number           1
        q_fpkm                  2.22
        q_fpkm_hi               33.33
        q_fpkm_lo               0.05
        q_status                'OK'
        association     :transcript
    end
end

# Factor.define :test_status do |test_status|
#     test_status.name = 'OK'
#     test_status.description = 'The ran successfully.'
#     test_status.association :differential_expression_test
# end