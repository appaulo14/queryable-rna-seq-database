class CreateGenes < ActiveRecord::Migration
  def up
    create_table :genes, :id => false do |t|
     #The primary key and some other columns are different for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        t.column :id, 'BIGINT UNSIGNED', :null => false
        t.column :dataset_id, 'BIGINT UNSIGNED', :null => false
      when /postgresql/
        t.column :id, 'bigserial', :null => false, :unique => true
        t.column :dataset_id, 'BIGINT', :null => false
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end

      t.string :name_from_program, :null => false
      t.timestamps
    end
    #Add primary key using execute statement because
    #   rails can't do BIGINT primary keys
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter_type
    when /mysql/
        execute('ALTER TABLE genes ADD PRIMARY KEY (id);')
        execute('ALTER TABLE genes ' +
                'MODIFY COLUMN id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;')
    when /postgresql/
        execute('ALTER TABLE genes ADD PRIMARY KEY (id);')
    else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
    end
    #Add foreign keys. The SQL is the same for both postgresql and mysql
#     execute('ALTER TABLE genes ADD CONSTRAINT jobs_fk ' + 
#             'FOREIGN KEY (job_id) REFERENCES jobs (id) ' + 
#             'ON UPDATE CASCADE ON DELETE RESTRICT;')
  end
  
  def down
      drop_table :genes
  end
end
