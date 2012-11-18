FactoryGirl.define do
    factory :job do
        email    'nietz111@ksu.edu'
    end
    
    factory :invalid_job, class: Job do
        email    nil
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
    
    factory :invalid_differential_expression_test, class: DifferentialExpressionTest do
        sample1          'Sample 1 Name'
        sample2          'Sample 2 Name'
        test_status_name 'OK'
        fpkm_x            1.1243
        fpkm_y            4343.2
        log2_y_over_x    332.11
        test_stat        0.0001
        p_value          'INVALID P VALUE'
        q_value          0.0005
        is_significant   true
    end
    
    factory :gene do
        name_from_program        'XLOC_00001'
        job
        differential_expression_test
    end
    
    factory :invalid_gene, class: Gene do
        name_from_program        nil
        job
        differential_expression_test
    end
    
    factory :transcript do
        name_from_program        'TCONS_00001'
        fasta_sequence           'ATKMBVCNSWD-GUYRHatkmbvcnswd-guyrh'
        gene
        job                     {gene.job}                 
        differential_expression_test
    end
    
    factory :invalid_transcript, class: Transcript do
        name_from_program        nil
        fasta_sequence           'ATKMBVCNSWD-GUYRHatkmbvcnswd-guyrh'
        gene
        job                     {gene.job}                 
        differential_expression_test
    end
    
    factory :fpkm_sample do
        sample_number           1
        q_fpkm                  2.22
        q_fpkm_hi               33.33
        q_fpkm_lo               0.05
        q_status                'OK'
        transcript
    end
    
    factory :invalid_fpkm_sample, class: FpkmSample do
        sample_number           1
        q_fpkm                  'INVALID FPKM'
        q_fpkm_hi               33.33
        q_fpkm_lo               0.05
        q_status                'OK'
        transcript
    end
end

# Factor.define :test_status do |test_status|
#     test_status.name = 'OK'
#     test_status.description = 'The ran successfully.'
#     test_status.association :differential_expression_test
# end