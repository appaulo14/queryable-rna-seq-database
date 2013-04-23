namespace :generate_test_files do
  desc "Generate upload files to simulate cuffdiff data"
  task :cuffdiff => :environment do
    if not Dir.exists?("#{Rails.root}/tmp/generated_test_files")
      Dir.mkdir("#{Rails.root}/tmp/generated_test_files/")
    end
    if Dir.exists?("#{Rails.root}/tmp/generated_test_files/cuffdiff")
      system("rm -r #{Rails.root}/tmp/generated_test_files/cuffdiff")
    end
    Dir.mkdir("#{Rails.root}/tmp/generated_test_files/cuffdiff")
    Dir.chdir("#{Rails.root}/tmp/generated_test_files/cuffdiff") 
    GenerateCuffdiffFiles.make_samples(3)
    GenerateCuffdiffFiles.make_genes(10000)
    GenerateCuffdiffFiles.make_transcripts()
    GenerateCuffdiffFiles.make_transcripts_fasta_file()
    GenerateCuffdiffFiles.make_isoform_fpkm_file()
#    GenerateCuffdiffFiles.make_transcript_det_files()
#    GenerateCuffdiffFiles.make_gene_det_files()
  end
  
  #I put all the methods in a class to because namespace collision
  class GenerateCuffdiffFiles
    def self.make_genes(needed_genes)
      genes_count = 1
      @genes = []
      while (genes_count <= needed_genes)
        @genes << "XLOC_" + "%05d" % genes_count
        genes_count += 1
      end
    end
    
    def self.make_transcripts()
      transcripts_count = 1
      @transcripts_with_gene = []
      @genes.each do |gene|
        (0..2).each do |i|
          transcript_with_gene = TranscriptWithGene.new()
          transcript_with_gene.gene = gene
          transcript_with_gene.transcript = "TCONS_" + ("%08d" % transcripts_count)
          @transcripts_with_gene << transcript_with_gene
        end
      end
    end
    
    def self.make_samples(samples_needed)
      @samples = []
      samples_count = 1
      while @samples.count < samples_needed
        @samples << "q#{samples_count}"
        samples_count += 1
      end
    end
    
    def self.make_transcripts_fasta_file
      file = File.new("transcripts.fasta","w+")
      #Create the transcript name
      @transcripts_with_gene.each do |transcript_with_gene|
        transcript = transcript_with_gene.transcript
        gene = transcript_with_gene.gene
        #Create a random fasta description and sequence
        nucleotide_counts = {'A' => rand(80..200),
                             'C' => rand(60..120),
                             'G' => rand(60..140),
                             'T' => rand(40..105)}
        random_fasta_sequence = Bio::Sequence::NA.randomize(nucleotide_counts)
        file.write(">#{transcript} gene=#{gene}\n")
        n = 0
        while 69*n < random_fasta_sequence.length
          file.write("#{random_fasta_sequence[(69*n)..(69*(n+1))].upcase}\n")
          n+=1
        end
      end
      file.close()
    end
    
    def self.make_isoform_fpkm_file()
      file = File.new("isoforms.fpkm_tracking",'w')
      #Write the header columns
      file.write("tracking_id	class_code\tnearest_ref_id\tgene_id")
      file.write("\tgene_short_name\ttss_id\tlocus\tlength\tcoverage")
      @samples.each do |sample|
        file.write("\t#{sample}_FPKM")
        file.write("\t#{sample}_conf_lo")
        file.write("\t#{sample}_conf_hi")
        file.write("\t#{sample}_status")
      end
      file.write("\n")
      @transcripts_with_gene.each do |transcript_with_gene|
        transcript = transcript_with_gene.transcript
        gene = transcript_with_gene.gene
        file.write("#{transcript}")
        random_class_code = TranscriptFpkmTrackingInformation::POSSIBLE_CLASS_CODES.sample
        file.write("\t#{random_class_code}\tNM_004359\t#{gene}\tNM_004359")
        file.write("\tTSS2\tchr19:486837-492886\t#{rand(0..2000)}\t-")
        @samples.each do |sample|
          random_status = FpkmSample::POSSIBLE_STATUSES.sample
          fpkm_hi = rand(0.0..62000.0)
          fpkm_lo = rand(0.0..fpkm_hi)
          fpkm = rand(fpkm_lo..fpkm_hi)
          file.write("\t#{fpkm}\t#{fpkm_lo}\t#{fpkm_hi}\t#{random_status}")
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
  
  class TranscriptWithGene < Struct.new :transcript, :gene
  end
end
