class UploadUtil
  require 'system_util.rb'
  
  def self.create_blast_database(file_path, dataset)
    SystemUtil.system!("#{Rails.root}/bin/blast/bin/makeblastdb " +
                        "-in #{file_path} " +
                        "-title #{dataset.id} " +
                        "-out #{dataset.blast_db_location} " +
                        "-hash_index -dbtype nucl ")
  end
  
  def self.rollback_blast_database(dataset)
    puts 'ROLLING BACK TEH BLAST DATABASE'
  end
  
  def generate_go_terms()
  end
end
