namespace :generate_test_files do
  desc "Generate upload files to simulate Trinity with EdgeR data"
  task :trinity => :environment do
    if not Dir.exists?("#{Rails.root}/tmp/generated_test_files")
      Dir.mkdir("#{Rails.root}/tmp/generated_test_files/")
    end
    if Dir.exists?("#{Rails.root}/tmp/generated_test_files/trinity")
      system("rm -r #{Rails.root}/tmp/generated_test_files/trinity")
    end
    Dir.mkdir("#{Rails.root}/tmp/generated_test_files/trinity")
    Dir.chdir("#{Rails.root}/tmp/generated_test_files/trinity") 
    GenerateTrinityFiles.make_genes(4000) #100,000 for XXXL, around 40,000 for XL, around 4,000 for regular
    GenerateTrinityFiles.make_transcripts()
    GenerateTrinityFiles.make_transcript_samples(3)
    GenerateTrinityFiles.make_trinity_fasta_file()
    GenerateTrinityFiles.make_transcript_fpkm_file()
    GenerateTrinityFiles.make_transcript_det_files()
    GenerateTrinityFiles.make_gene_samples(3)
    GenerateTrinityFiles.make_gene_fpkm_file()
    GenerateTrinityFiles.make_gene_det_files()
  end
  
  class GenerateTrinityFiles
    def self.make_genes(needed_genes)
      genes_count = 0
      @genes = []
      comp_count = 0
      c_count = 0
      while (comp_count * 3 < needed_genes)
        @genes << "comp#{comp_count}_c#{c_count}"
        if c_count >= 3
          comp_count += 1
          c_count = 0
        else
          c_count += 1
        end
      end
    end
    
    def self.make_transcripts()
      @transcripts = []
      @genes.each do |gene|
        (0..1).each do |seq_num|
          @transcripts << "#{gene}_seq#{seq_num}"
        end
      end
    end
    
    def self.make_transcript_samples(samples_needed)
      @transcript_samples = []
      while @transcript_samples.uniq.count < samples_needed
        @transcript_samples << "#{Faker::Lorem.word}_trans"
      end
      @transcript_samples = @transcript_samples.uniq
    end
    
    def self.make_gene_samples(samples_needed)
      @gene_samples = []
      while @gene_samples.uniq.count < samples_needed
        @gene_samples << "#{Faker::Lorem.word}_gene"
      end
      @tgene_samples = @gene_samples.uniq
    end
    
    def self.make_trinity_fasta_file
      file = File.new("Trinity.fasta","w+")
      #Create the transcript name
      @transcripts.each do |transcript|
      #Create a random fasta description and sequence
        nucleotide_counts = {'A' => rand(80..200),
                            'C' => rand(60..120),
                            'G' => rand(60..140),
                            'T' => rand(40..105)}
        random_fasta_sequence = Bio::Sequence::NA.randomize(nucleotide_counts)
        fasta_description = "#{transcript} len=#{random_fasta_sequence.length}"
        file.write(">#{fasta_description}\n")
        n = 0
        while 59*n < random_fasta_sequence.length
          file.write("#{random_fasta_sequence[(59*n)..(59*(n+1))].upcase}\n")
          n+=1
        end
      end
      file.close()
    end
    
    def self.make_transcript_fpkm_file()
      file = File.new("trans.TMM_normalized.FPKM",'w')
      #Write the header columns
      @transcript_samples.each do |sample|
        file.write("\t#{sample}")
      end
      file.write("\n")
      @transcripts.each do |transcript|
        file.write("#{transcript}")
        @transcript_samples.each do |sample|
          file.write(" #{rand(0.0..1000)}")
        end
        file.write("\n")
      end
      file.close()
    end
    
    def self.make_transcript_det_files()
      (0..@transcript_samples.count-1).each do |n1|
        ((n1+1)..@transcript_samples.count-1).each do |n2|
          file_name = "#{@transcript_samples[n1]}_vs_#{@transcript_samples[n2]}.results.txt"
          file = File.new("#{file_name}",'w')
          file.write("logConc	logFC	P.Value	adj.P.Val\n")
          @transcripts.each do |transcript|
            file.write(transcript)
            file.write("\t#{rand(-10.0..10.0)}") #Write the logConc
            file.write("\t#{rand(-10.0..10.0)}") #Write the logFC
            file.write("\t#{rand(0.0..1.0)}") #Write the P.value
            file.write("\t#{rand(0.0..1.0)}") #Write the adj.P.Val
            file.write("\n")
          end
          file.close()
        end
      end
    end
    
    def self.make_gene_fpkm_file()
      file = File.new("gene.TMM_normalized.FPKM",'w')
      #Write the header columns
      @gene_samples.each do |sample|
        file.write("\t#{sample}")
      end
      file.write("\n")
      @genes.each do |transcript|
        file.write("#{transcript}")
        @gene_samples.each do |sample|
          file.write(" #{rand(0.0..1000)}")
        end
        file.write("\n")
      end
      file.close()
    end
    
    def self.make_gene_det_files()
      (0..@gene_samples.count-1).each do |n1|
        ((n1+1)..@gene_samples.count-1).each do |n2|
          file_name = "#{@gene_samples[n1]}_vs_#{@gene_samples[n2]}.results.txt"
          file = File.new("#{file_name}",'w')
          file.write("logConc	logFC	P.Value	adj.P.Val\n")
          @genes.each do |transcript|
            file.write(transcript)
            file.write("\t#{rand(-10.0..10.0)}") #Write the logConc
            file.write("\t#{rand(-10.0..10.0)}") #Write the logFC
            file.write("\t#{rand(0.0..1.0)}") #Write the P.value
            file.write("\t#{rand(0.0..1.0)}") #Write the adj.P.Val
            file.write("\n")
          end
          file.close()
        end
      end
    end
  end
end
