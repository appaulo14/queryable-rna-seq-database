class CreateDatasets < ActiveRecord::Migration
  def up
    create_table :datasets, :id => false do |t|
      #The primary key is different for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
          t.column :id, 'BIGINT UNSIGNED', :null => false
      when /postgresql/
          t.column :id, 'bigserial', :null => false
      else
          throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end
      t.string :name, :null => false
      t.string :program_used, :null => false
      t.boolean :has_transcript_diff_exp, :null => false
      t.boolean :has_transcript_isoforms, :null => false
      t.boolean :has_gene_diff_exp, :null => false
      t.string :blast_db_location, :null => false
      t.integer :user_id, :null => false
      t.datetime :when_last_queried

      t.timestamps
    end
    
    #Add primary key using execute statement because
    #   rails can't do non-integer primary keys
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter_type
    when /mysql/
        execute('ALTER TABLE datasets ADD PRIMARY KEY (id);')
        execute('ALTER TABLE datasets MODIFY COLUMN id BIGINT UNSIGNED ' +
                'NOT NULL AUTO_INCREMENT;')
    when /postgresql/
        execute('ALTER TABLE datasets ADD PRIMARY KEY (id);')
    else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
    end
  end
  
  def down
    drop_table :datasets
  end
end
