class CreateDifferentialExpressionTests < ActiveRecord::Migration
  def up
    create_table :differential_expression_tests, :id=>false do |t|
      #The primary key and some other columns are different for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        t.column :id, 'BIGINT UNSIGNED', :null => false
        t.column :gene_id, 'BIGINT UNSIGNED'
        t.column :transcript_id, 'BIGINT UNSIGNED'
        t.column :sample_comparison_id, 'BIGINT UNSIGNED', :null => false
      when /postgresql/
        t.column :id, 'bigserial', :null => false, :unique => true
        t.column :gene_id, 'BIGINT'
        t.column :transcript_id, 'BIGINT'
        t.column :sample_comparison_id, 'BIGINT', :null => false
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end
      t.string :test_status, :null => false
      t.float :sample_1_fpkm, :null => false
      t.float :sample_2_fpkm, :null => false
      t.float :log_fold_change, :null => false
      t.float :test_statistic, :null => false
      t.float :p_value, :null => false
      t.float :fdr, :null => false

      #t.timestamps
    end
    #Add primary key using execute statement because
    #   rails can't do non-integer primary keys
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter_type
    when /mysql/
      execute('ALTER TABLE differential_expression_tests ADD PRIMARY KEY (id);')
      execute('ALTER TABLE differential_expression_tests ' +
                'MODIFY COLUMN id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;')
    when /postgresql/
      execute('ALTER TABLE differential_expression_tests ADD PRIMARY KEY (id);')
    else
      throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
    end
    #Add foreign keys. The SQL is the same for both postgresql and mysql
#     execute('ALTER TABLE differential_expression_tests ' +
#             'ADD CONSTRAINT genes_fk ' + 
#             'FOREIGN KEY (gene_id) REFERENCES genes (id) ' + 
#             'ON UPDATE CASCADE ON DELETE CASCADE;')
#     execute('ALTER TABLE differential_expression_tests ' +
#             'ADD CONSTRAINT transcripts_fk ' + 
#             'FOREIGN KEY (transcript_id) REFERENCES transcripts (id) ' + 
#             'ON UPDATE CASCADE ON DELETE CASCADE;')
#     execute('ALTER TABLE differential_expression_tests ' +
#             'ADD CONSTRAINT fpkm_sample_1_fk ' + 
#             'FOREIGN KEY (fpkm_sample_1_id) REFERENCES fpkm_samples (id) ' + 
#             'ON UPDATE CASCADE ON DELETE RESTRICT;')
#     execute('ALTER TABLE differential_expression_tests ' +
#             'ADD CONSTRAINT fpkm_sample_2_fk ' + 
#             'FOREIGN KEY (fpkm_sample_2_id) REFERENCES fpkm_samples (id) ' + 
#             'ON UPDATE CASCADE ON DELETE RESTRICT;')
  end
  
  def down
    drop_table :differential_expression_tests
  end
end
