class CreateDifferentialExpressionTests < ActiveRecord::Migration
  def up
    create_table :differential_expression_tests, :id=>false do |t|
      #The primary key and some other columns are different for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        t.column :id, 'BIGINT UNSIGNED', :null => false
        t.column :fpkm_sample_1_id, 'BIGINT UNSIGNED'
        t.column :fpkm_sample_2_id, 'BIGINT UNSIGNED'
        t.column :gene_id, 'BIGINT UNSIGNED'
        t.column :transcript_2_id, 'BIGINT UNSIGNED'
      when /postgresql/
        t.column :id, 'bigserial', :null => false, :unique => true
        t.column :fpkm_sample_1_id, 'BIGINT'
        t.column :fpkm_sample_2_id, 'BIGINT'
        t.column :gene_id, 'BIGINT'
        t.column :transcript_id, 'BIGINT'
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end
      t.string :test_status
      t.decimal :log_fold_change
      t.decimal :p_value
      t.decimal :q_value

      t.timestamps
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
  end
  
  def down
    drop_table :differential_expression_tests
  end
end
