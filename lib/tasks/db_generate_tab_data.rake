desc "Fill database with sample data"
task :generate_tab_data => :environment do
#     make_go_terms
#     make_admin_user #1
   #make_paul_cain_unconfirmed_user
#     make_unconfirmed_users(10)
   write_datasets('development')
#     make_genes #500
#     make_transcripts_and_blast_databases('dev')
#     make_samples
#     make_sample_comparisons_and_differential_expression_tests
#     make_fpkm_samples #1000
#     make_transcript_fpkm_tracking_information #1000#1000
#     make_transcript_has_go_terms #1000
      @datasets_count = 0
      @genes_counts = 0
      @transcripts_count = 0
      @samples_count = 0
end

def make_admin_user
  print 'Small Populating users...'
  @user = User.new(:email => 'nietz111@ksu.edu')
  @user.name = Faker::Name.name
  @user.description = Faker::Lorem.paragraph
  @user.password = 'cis895'
  @user.password_confirmation = 'cis895'
  @user.admin = true
  @user.skip_confirmation!
  @user.save!
  puts 'Done'
end

def make_paul_cain_unconfirmed_user
  print 'Making paul cain unconfirmed user.'
  user = User.new(:email => "paul_edward_cain@outlook.com")
  user.name = Faker::Name.name
  user.description = Faker::Lorem.paragraph
  user.password = 'cis895'
  user.password_confirmation = 'cis895'
  user.skip_confirmation!
  user.save!
  user.confirmed_at = nil
  user.save!
  puts 'Done'
end

def make_unconfirmed_users(number_of_users)
  print 'Making unconfirmed users.'
  (1..number_of_users).each do |n|
    user = User.new(:email => "#{Faker::Internet.email}.edu")
    user.name = Faker::Name.name
    user.description = Faker::Lorem.paragraph
    user.password = 'cis895'
    user.password_confirmation = 'cis895'
    user.skip_confirmation!
    user.save!
    user.confirmed_at = nil
    user.save!
  end
  puts 'Done'
end


def write_datasets(env)
  print 'Populating datasets...'
  f = File.new('datasets.tab','w')
  @user = User.first
  (1..20000).each do |n|
    name = "Dataset_#{n}"
    ds = Dataset.new(:user => @user, 
                    :name => name,
                    #The Blast database will actually be created later
                    :blast_db_location => "db/blast_databases/#{env}/#{n}",
                    :has_transcript_diff_exp => true,
                    :has_transcript_isoforms => true,
                    :has_gene_diff_exp       => true,
                    :program_used            => 'cuffdiff')
    fs_string = ""
    ds.attribute_names.each do |attr_name|
      fs_string+= "#{ds.attributes[attr_name]}\t"
    end
    fs_string.strip()
    f.write("#{fs_string}\n")
  end
  f.close
  puts 'Done'
end

def write_genes
  print 'Populating genes...'
  f = File.new('genes.tab','w')
  Dataset.all.each do |ds|
    gene_count = 0
    5000.times do |n|
      gene = Gene.new(:name_from_program => Faker::Lorem.word,
                          :dataset => ds)
      gene_count += 1
      
      fs_string = ""
      ds.attribute_names.each do |attr_name|
        fs_string+= "#{ds.attributes[attr_name]}\t"
      end
      fs_string.strip()
      f.write("#{fs_string}\n")
      end
  end
  f.close
  puts 'Done'
end

def make_transcripts_and_blast_databases(env)
  print 'Populating transcripts and blast databases...'
  f = File.new('transcripts.tab','w')
  #Make the blast databases directory if it does not exist
  if not Dir.exists?('db/blast_databases')
    Dir.mkdir('db/blast_databases')
  end
  if not Dir.exists?("db/blast_databases/#{env}")
    Dir.mkdir("db/blast_databases/#{env}")
  end
  #Loop through all the datasets, giving all the genes in the dataset a 
  #     random number of transcripts
  Dataset.all.each do |ds|
    #Make a transcript counter used for naming transcripts
    transcript_count = 0
    #Create a temporary file to use to create the blast database
    tmpfasta = Tempfile.new('tmpfasta')
    ds.genes.each do |gene|
      rand(1..3).times do |n|
        #Create the transcript name
        transcript_name = "TCONS_#{transcript_count}"
        #Create a random fasta description and sequence
        fasta_description = "#{transcript_name} gene=#{gene.name_from_program}"
        nucleotide_counts = {'a' => rand(40..100),
                             'c' => rand(30..61),
                             'g' => rand(30..71),
                             't' => rand(20..55)}
        random_fasta_sequence = Bio::Sequence::NA.randomize(nucleotide_counts)
        tmpfasta.write(">#{fasta_description}\n")
        tmpfasta.write("#{random_fasta_sequence}\n")
        #Create the transcript
        transcript = 
            Transcript.new(:dataset => ds,
                               :gene => gene,
                               :name_from_program => transcript_name)
       
        transcript_count += 1
      end
    end
    tmpfasta.rewind
    tmpfasta.close
    #Create the blast database file for the dataset and save its location
    is_success = system("bin/blast/bin/makeblastdb " +
                     "-in #{tmpfasta.path} -title #{ds.id}_db " +
                     "-parse_seqids " +
                     "-out #{ds.blast_db_location} -hash_index -dbtype nucl ")
    exit if is_success == false
    #Close and unlink the temporary file when finished
    tmpfasta.unlink
  end
  f.close
  puts 'Done'
end

def make_samples
  print 'Populating samples...'
  Dataset.all.each do |ds|
    3.times do |n|
      Sample.create!(:dataset => ds,
                     :name => Faker::Lorem.word,
                     :sample_type => 'both')
    end
  end
  puts 'Done'
end

def make_sample_comparisons_and_differential_expression_tests
  print 'Populating samples comparisons...'
  Dataset.all.each do |ds|
    (0..ds.samples.count-1).each do |n1|
      ((n1+1)..ds.samples.count-1).each do |n2|
        sample_cmp = SampleComparison.create!(:sample_1 => ds.samples[n1],
                                                :sample_2 => ds.samples[n2])
        ds.genes.each do |gene|
          sample_1_fpkm = rand(0.0..1000)
          sample_2_fpkm = rand(0.0..1000)
          random_test_status = 
               DifferentialExpressionTest::POSSIBLE_TEST_STATUSES.sample
           DifferentialExpressionTest.create!(
             :gene => gene,
             :sample_comparison => sample_cmp,
             :test_status => random_test_status,
             :sample_1_fpkm => sample_1_fpkm,
             :sample_2_fpkm => sample_2_fpkm,
             :test_status => random_test_status,
             :log_fold_change => Math.log2(sample_1_fpkm/sample_2_fpkm),
             :test_statistic => rand(0.0..1.0),
             :p_value => rand(0.0..1.0),
             :fdr => rand(0.0..1.0)
           )
        end
        
        ds.transcripts.each do |transcript|
          sample_1_fpkm = rand(0.0..1000)
          sample_2_fpkm = rand(0.0..1000)
          random_test_status = 
               DifferentialExpressionTest::POSSIBLE_TEST_STATUSES.sample
           DifferentialExpressionTest.create!(
             :transcript => transcript,
             :sample_comparison => sample_cmp,
             :test_status => random_test_status,
             :sample_1_fpkm => sample_1_fpkm,
             :sample_2_fpkm => sample_2_fpkm,
             :test_status => random_test_status,
             :log_fold_change => Math.log2(sample_1_fpkm/sample_2_fpkm),
             :test_statistic => rand(0.0..1.0),
             :p_value => rand(0.0..1.0),
             :fdr => rand(0.0..1.0)
           )
        end
      end
    end
  end
  puts 'Done'
end

def make_fpkm_samples
  print 'Populating FPKM samples...'
  Dataset.all.each do |ds|
    #Create fpkm samples with random values for the transcripts
    ds.transcripts.each do |transcript|
      random_status = FpkmSample::POSSIBLE_STATUSES.sample
      ds.samples.each do |sample|
        fpkm_hi = rand(0.0..62000.0)
        fpkm_lo = rand(0.0..fpkm_hi)
        fpkm = rand(fpkm_lo..fpkm_hi)
        FpkmSample.create!(:transcript => transcript,
                           :sample => sample,
                           :fpkm => fpkm, 
                           :fpkm_hi => fpkm_hi, 
                           :fpkm_lo => fpkm_lo, 
                           :status => random_status)
      end
    end
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

def make_go_terms
  print 'Populating GO terms...'
  #Read the go terms file, writing the go terms to the database
  go_term_file = File.open('lib/tasks/GO.terms_and_ids')
  count = 0
  start_time = Time.now.to_i
  while (not go_term_file.eof?)
    line = go_term_file.readline
    next if line.match(/\AGO/).nil? #skip if line has no term 
    go_id, go_term = line.split(/\t/)
    GoTerm.create!(:id => go_id, :term => go_term)
    count += 1
    #break if count > 1000
  end
  end_time = Time.now.to_i
  puts "Wrote #{count} go terms"
  puts "Writing took #{end_time - start_time} seconds"
  puts 'Done'
end

def make_transcript_has_go_terms
  print 'Populating transcript_has_go_terms table...'
  Dataset.all.each do |ds|
    ds.transcripts.each do |t|
      rand(0..3).times do |n|
        random_go_term = GoTerm.all.sample
        redo if t.go_terms.include?(random_go_term)
        TranscriptHasGoTerm.create!(:transcript => t, 
                                    :go_term => random_go_term)
      end
    end
  end
  puts 'Done'
end