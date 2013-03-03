#!/usr/bin/ruby

#Open the files for reading
trinity_fasta_file = File.open('Trinity.fasta','r')
gene_fpkm_file = File.open('genes.matrix.TMM_normalized.FPKM','r')
transcript_fpkm_file = File.open('transcripts.matrix.TMM_normalized.FPKM','r')
genes = {}
gene_fpkm_file.readline
while not gene_fpkm_file.eof?
  gene_line = gene_fpkm_file.readline
  gene_cells = gene_line.split("\t")
  gene = gene_cells[0]
  match = false
  transcript_fpkm_file.readline
  while not transcript_fpkm_file.eof?
    transcript_line = transcript_fpkm_file.readline
    cells = transcript_line.split("\t")
    transcript = cells[0]
    if transcript.match(/#{gene}_/)
      puts "gene = #{gene}, transcript = #{transcript}"
      match = true
      break
    end
  end
  transcript_fpkm_file.rewind
  if match == false
    puts "false"
  end
end

#Close the files
trinity_fasta_file.close
gene_fpkm_file.close
transcript_fpkm_file.close