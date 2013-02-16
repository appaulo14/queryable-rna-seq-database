class AddForeignKeys < ActiveRecord::Migration
  def up
    #Dataset foreign keys
    execute('ALTER TABLE datasets ADD CONSTRAINT datasets_users_fk ' + 
            'FOREIGN KEY (user_id) REFERENCES users (id) ' + 
            'ON UPDATE CASCADE ON DELETE RESTRICT;')
    #Transcript foreign keys
    execute('ALTER TABLE transcripts ADD CONSTRAINT transripts_datasets_fk ' + 
            'FOREIGN KEY (dataset_id) REFERENCES datasets (id) ' + 
            'ON UPDATE CASCADE ON DELETE RESTRICT;')
    execute('ALTER TABLE transcripts ADD CONSTRAINT transripts_genes_fk ' +
            'FOREIGN KEY (gene_id) REFERENCES genes (id) ' +
            'ON UPDATE CASCADE ON DELETE RESTRICT;')
    #Transcript fpkm tracking foreign key
    execute('ALTER TABLE transcript_fpkm_tracking_informations ' +
            'ADD CONSTRAINT transcript_fpkm_tracking_informations_transripts_fk ' +
            'FOREIGN KEY (transcript_id) REFERENCES transcripts (id) ' +
            'ON UPDATE CASCADE ON DELETE RESTRICT;')
    #Gene foreign keys
    execute('ALTER TABLE genes ADD CONSTRAINT genes_datasets_fk ' + 
            'FOREIGN KEY (dataset_id) REFERENCES datasets (id) ' + 
            'ON UPDATE CASCADE ON DELETE RESTRICT;')
    #Differential expression test foreign keys
    execute('ALTER TABLE differential_expression_tests ' +
            'ADD CONSTRAINT differential_expression_tests_genes_fk ' + 
            'FOREIGN KEY (gene_id) REFERENCES genes (id) ' + 
            'ON UPDATE CASCADE ON DELETE CASCADE;')
    execute('ALTER TABLE differential_expression_tests ' +
            'ADD CONSTRAINT differential_expression_tests_transcripts_fk ' + 
            'FOREIGN KEY (transcript_id) REFERENCES transcripts (id) ' + 
            'ON UPDATE CASCADE ON DELETE CASCADE;')
    execute('ALTER TABLE differential_expression_tests ' +
            'ADD CONSTRAINT differential_expression_tests_fpkm_sample_1_fk ' + 
            'FOREIGN KEY (fpkm_sample_1_id) REFERENCES fpkm_samples (id) ' + 
            'ON UPDATE CASCADE ON DELETE RESTRICT;')
    execute('ALTER TABLE differential_expression_tests ' +
            'ADD CONSTRAINT differential_expression_tests_fpkm_sample_2_fk ' + 
            'FOREIGN KEY (fpkm_sample_2_id) REFERENCES fpkm_samples (id) ' + 
            'ON UPDATE CASCADE ON DELETE RESTRICT;')
    #FPKM Sample foreign keys
    execute('ALTER TABLE fpkm_samples ' +
            'ADD CONSTRAINT fpkm_samples_genes_fk ' + 
            'FOREIGN KEY (gene_id) REFERENCES genes (id) ' + 
            'ON UPDATE CASCADE ON DELETE CASCADE;')
    execute('ALTER TABLE fpkm_samples ' +
            'ADD CONSTRAINT fpkm_samples_transcripts_fk ' + 
            'FOREIGN KEY (transcript_id) REFERENCES transcripts (id) ' + 
            'ON UPDATE CASCADE ON DELETE CASCADE;')
    execute('ALTER TABLE fpkm_samples ' +
            'ADD CONSTRAINT fpkm_samples_samples_fk ' + 
            'FOREIGN KEY (sample_id) REFERENCES samples (id) ' + 
            'ON UPDATE CASCADE ON DELETE CASCADE;')
  end

  def down
  end
end
