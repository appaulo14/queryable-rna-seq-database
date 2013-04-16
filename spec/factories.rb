require 'query_analysis/upload_cuffdiff.rb'
require 'query_analysis/upload_trinity_with_edger.rb'
require 'spec_helper'

FactoryGirl.define do
    factory :user do
      name                      {Faker::Name.name}
      email                     {"#{Faker::Internet.email}.edu"}
      password                  'cis895'
      password_confirmation     'cis895'
      description               {Faker::Lorem.paragraph}
      confirmed_at              {Time.now}
    end
    
    factory :go_term do
      id                        {"GO:#{rand().to_s[2..8]}"}
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
    factory :transcript do
        id                      {Transcript.count + 1}
        name_from_program       {Faker::Name.name}
        gene
        dataset                 #{build(:dataset, :id => 1)}
    end
    
    factory :transcript_fpkm_tracking_information do
      transcript
      class_code                'c'
      length                    100
    end
    
    factory :dataset do
      name                      {Faker::Name.name}
      program_used              'trinity_with_edger'
      has_transcript_diff_exp   true
      has_transcript_isoforms   true
      has_gene_diff_exp         true
      blast_db_location         'db/blast_databases/test/1_db'
      user
    end
    
    factory :sample do
      name                      {Faker::Name.name}
      sample_type                      'both'
      dataset
    end
    
    factory :sample_comparison do
      sample_1                 {FactoryGirl.create(:sample)}
      sample_2                 {FactoryGirl.create(:sample)}
    end
     
    factory :fpkm_sample do
        fpkm                  2.22
        fpkm_hi               33.33
        fpkm_lo               0.05
        status                'OK'
        transcript
        sample
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
    
    factory :upload_fasta_sequences, class: UploadFastaSequences do
      initialize_with           {new(FactoryGirl.create(:user))}
      after(:build)             {|object| object.set_attributes_and_defaults() }
      transcripts_fasta_file    {to_cuffdiff_uploaded_file(2,'transcripts.fasta')}
      dataset_name              {Faker::Name.name}
    end
    
    factory :upload_trinity_with_edger_with_2_samples, 
    class: UploadTrinityWithEdgeR do
      initialize_with           {new(FactoryGirl.create(:user))}
      after(:build)             {|object| object.set_attributes_and_defaults() }
      transcripts_fasta_file    {get_uploaded_trinity_fasta_file()}
      gene_diff_exp_files       {get_trinity_diff_exp_files('gene', 2)}
      transcript_diff_exp_files {get_trinity_diff_exp_files('trans', 2)}
      gene_fpkm_file            {get_trinity_gene_fpkm_file(2)}
      transcript_fpkm_file      {get_trinity_transcript_fpkm_file(2)}
      has_gene_diff_exp         '1'
      dataset_name              {Faker::Name.name}
    end
end
