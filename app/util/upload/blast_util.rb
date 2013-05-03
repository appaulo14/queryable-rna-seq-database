require 'system_util.rb'
require 'open3'

###
# Utility class for adding/removing blast databases.
class BlastUtil
  ###
  # Creates a blast database for the specified dataset using the 
  # given fasta file. Seq ids are parsed when creating the database.
  def self.makeblastdb_with_seqids(fasta_file_path, dataset)
    SystemUtil.system!("#{Rails.root}/bin/blast/bin/makeblastdb " +
                        "-in #{fasta_file_path} " +
                        "-title #{dataset.id} " +
                        "-out #{dataset.blast_db_location} " +
                        "-hash_index -parse_seqids -dbtype nucl ")
  end
  
  ###
  # Creates a blast database for the specified dataset using the 
  # given fasta file. Seq ids are not parsed when creating the database.
  def self.makeblastdb_without_seqids(fasta_file_path, dataset)
    SystemUtil.system!("#{Rails.root}/bin/blast/bin/makeblastdb " +
                        "-in #{fasta_file_path} " +
                        "-title #{dataset.id} " +
                        "-out #{dataset.blast_db_location} " +
                        "-hash_index -dbtype nucl ")
  end
  
  ###
  # Deletes the blast database for the specified dataset.
  def self.rollback_blast_database(dataset)
    return if dataset.nil?
    stdout, stderr, status = 
      Open3.capture3("ls db/blast_databases/#{Rails.env}/#{dataset.id}.*")
    if stderr.blank?
      system("rm db/blast_databases/#{Rails.env}/#{dataset.id}.*")
    end
  end
end
