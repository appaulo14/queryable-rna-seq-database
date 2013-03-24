require 'system_util.rb'
require 'open3'
  
class BlastUtil
  
  def self.create_blast_database(fasta_file_path, dataset)
    SystemUtil.system!("#{Rails.root}/bin/blast/bin/makeblastdb " +
                        "-in #{fasta_file_path} " +
                        "-title #{dataset.id} " +
                        "-out #{dataset.blast_db_location} " +
                        "-hash_index -parse_seqids -dbtype nucl ")
  end
  
  def self.rollback_blast_database(dataset)
    stdout, stderr, status = 
      Open3.capture3("ls db/blast_databases/#{Rails.env}/#{dataset.id}.*")
    if stderr.blank?
      system("rm db/blast_databases/#{Rails.env}/#{dataset.id}.*")
    end
  end
end
