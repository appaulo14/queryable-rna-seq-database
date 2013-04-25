class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.string :name, :null => false
      t.string :program_used, :null => false
      t.boolean :has_transcript_diff_exp, :null => false
      t.boolean :has_transcript_isoforms, :null => false
      t.boolean :has_gene_diff_exp, :null => false
      t.boolean :finished_uploading, :null => false
      t.string :go_terms_status, :null => false
      t.string :blast_db_location, :null => false
      t.integer :user_id, :null => false
      t.datetime :when_last_queried

      t.timestamps
    end
    
    #Add indexes
    add_index :datasets, :user_id
  end
end
