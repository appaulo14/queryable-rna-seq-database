class CreateDifferentialExpressionTests < ActiveRecord::Migration
  def up
    create_table :differential_expression_tests, :id=>false do |t|
      #The primary key and some other columns are different for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        bigserial = 'BIGINT UNSIGNED'
        big_int = 'BIGINT UNSIGNED'
        double = 'double'
      when /postgresql/
        bigserial = 'bigserial'
        big_int = 'BIGINT'
        double = 'double precision'
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end
      t.column :id, bigserial, :null => false, :unique => true
      t.column :gene_id, big_int
      t.column :transcript_id, big_int
      t.integer :sample_comparison_id, :null => false
      t.string :test_status
      t.column :sample_1_fpkm, double
      t.column :sample_2_fpkm, double
      t.column :log_fold_change, double, :null => false
      t.column :test_statistic, double
      t.column :p_value, double, :null => false
      t.column :fdr, double, :null => false
	

      #t.timestamps
    end
    #Add indexes
    add_index :differential_expression_tests, :gene_id
    add_index :differential_expression_tests, :transcript_id
    add_index :differential_expression_tests, :sample_comparison_id
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
