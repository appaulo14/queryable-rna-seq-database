require 'tempfile'

namespace :db do
  desc "Fill database with sample data"
  task :make_blast_databases => :environment do
    make_blast_databases 

  end
end

def make_blast_databases
  print 'Populating blast databases...'
  #Make the blast databases directory if it does not exist
  if not Dir.exists?('db/blast_databases')
    Dir.mkdir('db/blast_databases')
  end
  Dataset.all.each do |ds|
    #Create a temporary file to use to create the blast database
    tmpfasta = Tempfile.new('tmpfasta')
    #Write all the fastas for the dataset to the temporary file
    ds.transcripts.each do |transcript|
      tmpfasta.write(">#{transcript.fasta_description}\n")
      tmpfasta.write("#{transcript.fasta_sequence}\n")
    end
    tmpfasta.rewind
    tmpfasta.close
    #Create the blast database file for the dataset and save its location
    success = system("bin/blast/bin/makeblastdb " +
                     "-in #{tmpfasta.path} -title #{ds.id}_db " +
                     "-out #{ds.blast_db_location} -hash_index -dbtype nucl " +
                     "-parse_seqids")
    exit if success == false
    #Close and unlink the temporary file when finished
    tmpfasta.unlink
  end
  puts 'Done'
end