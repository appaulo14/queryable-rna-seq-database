require 'query_analysis/upload_cuffdiff.rb'
require 'spec_helper'

FactoryGirl.define do
    factory :user do
      name                      {Faker::Name.name}
      email                     {Faker::Internet.email}
      password                  'cis895'
      password_confirmation     'cis895'
      description               {Faker::Lorem.paragraph}
      confirmed_at              {Time.now}
    end
    
    factory :go_term do
      id                        'GO:0000026'
      term                      'alpha-1,2-mannosyltransferase activity'
    end
    
    factory :transcript_has_go_term do
      transcript                #{build(:transcript)}
      go_term
    end
    
    factory :differential_expression_test do
      gene
      sample_comparison
      test_status               'OK'
      sample_1_fpkm             8.01089
      sample_2_fpkm             8.551545
      log_fold_change           0.06531
      test_statistic            0.55
      p_value                   0.05
      fdr                       0.03
    end
#     
#     factory :invalid_differential_expression_test, class: DifferentialExpressionTest do
#         sample1          'Sample 1 Name'
#         sample2          'Sample 2 Name'
#         test_status_name 'OK'
#         fpkm_x            1.1243
#         fpkm_y            4343.2
#         log2_y_over_x    332.11
#         test_stat        0.0001
#         p_value          'INVALID P VALUE'
#         q_value          0.0005
#         is_significant   true
#     end
#     
    factory :gene do
        name_from_program        {Faker::Name.name}
        dataset
    end
#     
#     factory :invalid_gene, class: Gene do
#         name_from_program        nil
#         job
#         differential_expression_test
#     end
#     
    #TODO: Fix me
    factory :transcript do
        id                      {Transcript.count + 1}
        name_from_program       'TCONS_00001'
        dataset                 #{build(:dataset, :id => 1)}
    end
    
    factory :dataset do
      name                      {Faker::Name.name}
      program_used              :trinity_with_edger
      has_transcript_diff_exp   true
      has_transcript_isoforms   true
      has_gene_diff_exp         true
      blast_db_location         'db/blast_databases/test/1_db'
      user
    end
    
    factory :sample do
      name                      {Faker::Name.name}
      dataset
    end
    
    factory :sample_comparison do
      sample_1                 {FactoryGirl.create(:sample)}
      sample_2                 {FactoryGirl.create(:sample)}
    end
    
#     
#     factory :invalid_transcript, class: Transcript do
#         name_from_program        nil
#         fasta_sequence           'ATKMBVCNSWD-GUYRHatkmbvcnswd-guyrh'
#         gene
#         job                     {gene.job}                 
#         differential_expression_test
#     end
#     
    factory :fpkm_sample do
        fpkm                  2.22
        fpkm_hi               33.33
        fpkm_lo               0.05
        status                'OK'
        transcript
        sample
    end
    
    factory :upload_cuffdiff_with_1_sample, class: UploadCuffdiff do
      initialize_with           {new(FactoryGirl.create(:user))}
      after(:build)             {|object| object.set_attributes_and_defaults() }
      transcripts_fasta_file    {to_cuffdiff_uploaded_file(1,'transcripts.fasta')}
      transcript_isoforms_file  {to_cuffdiff_uploaded_file(1,'isoforms.fpkm_tracking')}
      has_diff_exp              '0'
      has_transcript_isoforms   '1'
      dataset_name              {Faker::Name.name}
    end
    
    factory :upload_cuffdiff_with_2_samples, class: UploadCuffdiff do
      initialize_with           {new(FactoryGirl.create(:user))}
      after(:build)             {|object| object.set_attributes_and_defaults() }
      transcripts_fasta_file    {to_cuffdiff_uploaded_file(2,'transcripts.fasta')}
      transcript_diff_exp_file  {to_cuffdiff_uploaded_file(2,'isoform_exp.diff')}
      gene_diff_exp_file        {to_cuffdiff_uploaded_file(2,'gene_exp.diff')}
      transcript_isoforms_file  {to_cuffdiff_uploaded_file(2,'isoforms.fpkm_tracking')}
      has_diff_exp              '1'
      has_transcript_isoforms   '1'
      dataset_name              {Faker::Name.name}
    end
    
    factory :upload_cuffdiff_with_3_samples, class: UploadCuffdiff do
      initialize_with           {new(FactoryGirl.create(:user))}
      after(:build)             {|object| object.set_attributes_and_defaults() }
      transcripts_fasta_file    {to_cuffdiff_uploaded_file(3,'transcripts.fasta')}
      transcript_diff_exp_file  {to_cuffdiff_uploaded_file(3,'isoform_exp.diff')}
      gene_diff_exp_file        {to_cuffdiff_uploaded_file(3,'gene_exp.diff')}
      transcript_isoforms_file  {to_cuffdiff_uploaded_file(3,'isoforms.fpkm_tracking')}
      has_diff_exp              '1'
      has_transcript_isoforms   '1'
      dataset_name              {Faker::Name.name}
    end
    
    factory :upload_cuffdiff_with_4_samples, class: UploadCuffdiff do
      initialize_with           {new(FactoryGirl.create(:user))}
      after(:build)             {|object| object.set_attributes_and_defaults() }
      transcripts_fasta_file    {to_cuffdiff_uploaded_file(4,'transcripts.fasta')}
      transcript_diff_exp_file  {to_cuffdiff_uploaded_file(4,'isoform_exp.diff')}
      gene_diff_exp_file        {to_cuffdiff_uploaded_file(4,'gene_exp.diff')}
      transcript_isoforms_file  {to_cuffdiff_uploaded_file(4,'isoforms.fpkm_tracking')}
      has_diff_exp              '1'
      has_transcript_isoforms   '1'
      dataset_name              {Faker::Name.name}
    end
#     uc = FactoryGirl.build(:upload_cuffdiff_with_2_samples)
#     factory :invalid_fpkm_sample, class: FpkmSample do
#         sample_number           1
#         q_fpkm                  'INVALID FPKM'
#         q_fpkm_hi               33.33
#         q_fpkm_lo               0.05
#         q_status                'OK'
#         transcript
#     end
end

# Factor.define :test_status do |test_status|
#     test_status.name = 'OK'
#     test_status.description = 'The ran successfully.'
#     test_status.association :differential_expression_test
# end