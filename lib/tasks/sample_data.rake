require 'faker'
require 'bio'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    make_users
    make_datasets
    make_genes
    make_transcripts
    make_fpkm_samples
    make_transcript_fpkm_tracking_information
#     make_differential_expression_tests
#     make_go_terms
#     make_gene_has_go_terms
  end
end

def make_users
    @user = User.new(:email => 'nietz111@ksu.edu')
    @user.password = 'cis895'
    @user.password_confirmation = 'cis895'
    @user.save!
end

def make_datasets
  10.times do |n|
    Dataset.create!(:user => @user, :name => Faker::Lorem.word)
  end
end

def make_genes
  #Create 1000 genes with random datasets
  all_datasets = Dataset.all
  dataset_count = Dataset.count
  1000.times do |n|
    gene = Gene.create!(:name_from_program => Faker::Name.name,
                        :dataset => all_datasets[rand(dataset_count)])
  end
end

def make_transcripts
  #Create 1000 transcripts with random datasets and genes
  all_datasets = Dataset.all
  dataset_count = Dataset.count
  all_genes = Gene.all
  gene_count = Gene.count
  1000.times do |n|
    nucleotide_counts = {'a' => rand(10),
                         'c' => rand(21),
                         'g' => rand(31),
                         't' => rand(15)}
    random_fasta_sequence = Bio::Sequence::NA.randomize(nucleotide_counts)
    transcript = 
        Transcript.create!(:dataset => all_datasets[rand(dataset_count)],
                           :gene => all_genes[rand(gene_count)],
                           :fasta_sequence => random_fasta_sequence,
                           :name_from_program => "Transcript_#{n}",
                           :fasta_description => Faker::Lorem.sentence)
  end
end

def make_fpkm_samples
  #Create 500 fpkm samples with random transcripts
  all_genes = Gene.all
  gene_count = Gene.count
  all_transcripts = Transcript.all
  transcript_count = Transcript.count
  500.times do |n|
    fpkm_hi = rand(0.0..62000.0)
    fpkm_lo = rand(0.0..fpkm_hi)
    fpkm = rand(fpkm_lo..fpkm_hi)
    random_status = 
      FpkmSample::POSSIBLE_STATUSES[rand(FpkmSample::POSSIBLE_STATUSES.count)]
    FpkmSample.create!(:transcript => all_transcripts[rand(transcript_count)],
                       :sample_name => Faker::Lorem.word,
                       :fpkm => fpkm, 
                       :fpkm_hi => fpkm_hi, 
                       :fpkm_lo => fpkm_lo, 
                       :status => random_status)
  end
  #Create 500 fpkm samples with random genes
  500.times do |n|
    fpkm_hi = rand(0.0..62000.0)
    fpkm_lo = rand(0.0..fpkm_hi)
    fpkm = rand(fpkm_lo..fpkm_hi)
    random_status = 
      FpkmSample::POSSIBLE_STATUSES[rand(FpkmSample::POSSIBLE_STATUSES.count)]
    FpkmSample.create!(:gene => all_genes[rand(gene_count)],
                       :sample_name => Faker::Lorem.word,
                       :fpkm => fpkm, 
                       :fpkm_hi => fpkm_hi, 
                       :fpkm_lo => fpkm_lo, 
                       :status => random_status)
  end
end

def make_transcript_fpkm_tracking_information
  Transcript.all.each do |t|
    random_class_code = TranscriptFpkmTrackingInformation::POSSIBLE_CLASS_CODES[rand(TranscriptFpkmTrackingInformation::POSSIBLE_CLASS_CODES.count)]
    TranscriptFpkmTrackingInformation.create!(:transcript => t,
                                              :class_code => random_class_code,
                                              :length => rand(1000000),
                                              :coverage => rand(1000000.0))
  end
end
