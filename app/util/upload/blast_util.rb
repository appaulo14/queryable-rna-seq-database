require 'system_util.rb'
require 'open3'
  
class BlastUtil
  
  def self.makeblastdb_with_seqids(fasta_file_path, dataset)
    SystemUtil.system!("#{Rails.root}/bin/blast/bin/makeblastdb " +
                        "-in #{fasta_file_path} " +
                        "-title #{dataset.id} " +
                        "-out #{dataset.blast_db_location} " +
                        "-hash_index -parse_seqids -dbtype nucl ")
  end
  
  def self.makeblastdb_without_seqids(fasta_file_path, dataset)
    SystemUtil.system!("#{Rails.root}/bin/blast/bin/makeblastdb " +
                        "-in #{fasta_file_path} " +
                        "-title #{dataset.id} " +
                        "-out #{dataset.blast_db_location} " +
                        "-hash_index -dbtype nucl ")
  end
  
  def self.rollback_blast_database(dataset)
    return if dataset.nil?
    stdout, stderr, status = 
      Open3.capture3("ls db/blast_databases/#{Rails.env}/#{dataset.id}.*")
    if stderr.blank?
      system("rm db/blast_databases/#{Rails.env}/#{dataset.id}.*")
    end
  end
end
