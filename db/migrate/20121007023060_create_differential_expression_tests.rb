class CreateDifferentialExpressionTests < ActiveRecord::Migration
  def up
    create_table :differential_expression_tests, :id=>false do |t|
        #The primary key and some other columns are different for mysql vs postgresql
        adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
        case adapter_type
        when /mysql/
            t.column :id, 'BIGINT UNSIGNED', :null => false
        when /postgresql/
            t.column :id, 'bigserial', :null => false
        else
            throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
        end
      t.string :sample1, :null => false
      t.string :sample2, :null => false
      t.string :test_status_name, :null => false
      t.double :FPKMx, :null => false
      t.double :FPKMy, :null => false
      t.double :log2_y_over_x, :null => false
      t.double :test_stat, :null => false
      t.double :p_value, :null => false
      t.double :q_value, :null => false
      t.boolean :significant?, :null => false

      t.timestamps
    end
    #Add primary key using execute statement because
    #   rails can't do non-integer primary keys
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter_type
    when /mysql/
        execute('ALTER TABLE differential_expression_tests ADD PRIMARY KEY (id);')
        execute('ALTER TABLE differential_expression_tests MODIFY COLUMN id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;')
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
