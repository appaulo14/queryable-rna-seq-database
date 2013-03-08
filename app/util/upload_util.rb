class Upload_Util
  require 'util/system_util.rb'
  
  def create_blast_database!(file_path, dataset)
    system!("#{Rails.root}/bin/blast/bin/makeblastdb " +
      "-in #{file_path} " +
      "-title #{dataset.id} " +
      "-out #{dataset.blast_db_location} " +
      "-hash_index -dbtype nucl ")
  end
  
  def rollback_blast_database!(dataset)
  end
  
  def generate_go_terms!()
  end
end
