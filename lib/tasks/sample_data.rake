require 'faker'
require 'bio'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    #Generate the data
    make_users
    make_datasets
    make_genes
    make_transcripts
    make_fpkm_samples
    make_transcript_fpkm_tracking_information
    make_differential_expression_tests
    make_go_terms
    make_gene_has_go_terms
  end
end

def make_users
  print 'Populating users...'
  @user = User.new(:email => 'nietz111@ksu.edu')
  @user.password = 'cis895'
  @user.password_confirmation = 'cis895'
  @user.save!
  puts 'Done'
end

def make_datasets
  print 'Populating datasets...'
  10.times do |n|
    Dataset.create!(:user => @user, :name => Faker::Lorem.word)
  end
  puts 'Done'
end

def make_genes
  print 'Populating genes...'
  #Get an array of all the datasets to use for random selection
  all_datasets = Dataset.all
  #Create 1000 genes with random datasets
  1000.times do |n|
    gene = Gene.create!(:name_from_program => Faker::Name.name,
                        :dataset => all_datasets.sample)
  end
  puts 'Done'
end

def make_transcripts
  print 'Populating transcripts...'
  #Get arrays of all the datasets and genes to use for random selection
  all_datasets = Dataset.all
  all_genes = Gene.all
  #Create 1000 transcripts with random datasets and genes
  1000.times do |n|
    #Create a random fasta sequence
    nucleotide_counts = {'a' => rand(10),
                         'c' => rand(21),
                         'g' => rand(31),
                         't' => rand(15)}
    random_fasta_sequence = Bio::Sequence::NA.randomize(nucleotide_counts)
    #Create the transcript
    transcript = 
        Transcript.create!(:dataset => all_datasets.sample,
                           :gene => all_genes.sample,
                           :fasta_sequence => random_fasta_sequence,
                           :name_from_program => "Transcript_#{n}",
                           :fasta_description => Faker::Lorem.sentence)
  end
  puts 'Done'
end

def make_fpkm_samples
  print 'Populating FPKM samples...'
  #Get arrays of all the genes and transcripts to use for random selection
  all_genes = Gene.all
  all_transcripts = Transcript.all
  #Create some random sample names
  random_sample_names = []
  5.times do |n|
    random_sample_names << Faker::Lorem.word
  end
  #Create 500 fpkm samples with random values
  500.times do |n|
    fpkm_hi = rand(0.0..62000.0)
    fpkm_lo = rand(0.0..fpkm_hi)
    fpkm = rand(fpkm_lo..fpkm_hi)
    random_status = FpkmSample::POSSIBLE_STATUSES.sample
    FpkmSample.create!(:transcript => all_transcripts.sample,
                       :sample_name => random_sample_names.sample,
                       :fpkm => fpkm, 
                       :fpkm_hi => fpkm_hi, 
                       :fpkm_lo => fpkm_lo, 
                       :status => random_status)
  end
  #Create 500 fpkm samples with random values
  500.times do |n|
    fpkm_hi = rand(0.0..62000.0)
    fpkm_lo = rand(0.0..fpkm_hi)
    fpkm = rand(fpkm_lo..fpkm_hi)
    random_status = FpkmSample::POSSIBLE_STATUSES.sample
    FpkmSample.create!(:gene => all_genes.sample,
                       :sample_name => random_sample_names.sample,
                       :fpkm => fpkm, 
                       :fpkm_hi => fpkm_hi, 
                       :fpkm_lo => fpkm_lo, 
                       :status => random_status)
  end
  puts 'Done'
end

def make_transcript_fpkm_tracking_information
  print 'Populating transcript fpkm tracking information...'
  #Create Transcript FPKM Tracking Information data with random values
  Transcript.all.each do |t|
    random_class_code = TranscriptFpkmTrackingInformation::POSSIBLE_CLASS_CODES.sample
    TranscriptFpkmTrackingInformation.create!(:transcript => t,
                                              :class_code => random_class_code,
                                              :length => rand(1000000),
                                              :coverage => rand(1000000.0))
  end
  puts 'Done'
end

def make_differential_expression_tests
  print 'Populating differential expression tests...'
  #Get arrays of data to use for random selection
  all_genes = Gene.all
  all_transcripts = Transcript.all
  all_fpkm_samples = FpkmSample.all
  #Create 500 differnetial expresssion tests with random values
  5000.times do |n|
    #Get two random fpkm samples, but make sure they're not the same one
    while (true)
      random_fpkm_sample_1 = all_fpkm_samples.sample
      random_fpkm_sample_2 = all_fpkm_samples.sample
      break if random_fpkm_sample_1.id != random_fpkm_sample_2.id
    end 
    random_transcript = all_transcripts.sample
    random_test_status = DifferentialExpressionTest::POSSIBLE_TEST_STATUSES.sample
    DifferentialExpressionTest.create!(:fpkm_sample_1 => random_fpkm_sample_1,
                                       :fpkm_sample_2 => random_fpkm_sample_2,
                                       :transcript => random_transcript,
                                       :test_status => random_test_status,
                                       :log_fold_change => rand(0.0..1.0),
                                       :p_value => rand(0.0..1.0),
                                       :q_value => rand(0.0..1.0))
  end
  #Create 500 differential expresssion tests with random values
  5000.times do |n|
    #Get two random fpkm samples, but make sure they're not the same one
    while (true)
      random_fpkm_sample_1 = all_fpkm_samples.sample
      random_fpkm_sample_2 = all_fpkm_samples.sample
      break if random_fpkm_sample_1.id != random_fpkm_sample_2.id
    end 
    random_gene = all_genes.sample
    random_test_status = DifferentialExpressionTest::POSSIBLE_TEST_STATUSES.sample
    DifferentialExpressionTest.create!(:fpkm_sample_1 => random_fpkm_sample_1,
                                       :fpkm_sample_2 => random_fpkm_sample_2,
                                       :gene => random_gene,
                                       :test_status => random_test_status,
                                       :log_fold_change => rand(0.0..1.0),
                                       :p_value => rand(0.0..1.0),
                                       :q_value => rand(0.0..1.0))
  end
  puts 'Done'
end

def make_go_terms
  print 'Populating GO terms...'
  #Read the go terms file, writing the go terms to the database
  go_term_file = File.open('lib/tasks/GO.terms_and_ids')
  while (not go_term_file.eof?)
    line = go_term_file.readline
    next if line.match(/\AGO/).nil? #skip if line has no term 
    go_id, go_term = line.split(/\t/)
    GoTerm.create!(:id => go_id, :term => go_term)
  end
  puts 'Done'
end

def make_gene_has_go_terms
  print 'Populating gene_has_go_terms table...'
  #Get arrays of all the genes and go terms to use for random selection
  all_genes = Gene.all
  all_go_terms = GoTerm.all
  #Create 100,000 gene has go terms with random values
  100_000.times do |n|
    random_gene = all_genes.sample
    random_go_term = all_go_terms.sample
    GeneHasGoTerm.create!(:gene => random_gene, :go_term => random_go_term)
  end
  puts 'Done'
end
