class CreateSamples < ActiveRecord::Migration
  def up
    create_table :samples, :id => false do |t|
      #The primary key and some other columns are different 
      # for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        t.column :id, 'BIGINT UNSIGNED', :null => false
      when /postgresql/
        t.column :id, 'bigserial', :null => false
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end
      t.string :name
      t.integer :dataset_id, :null => false

      #t.timestamps
    end
    
    #Add primary key using execute statement because
    #   rails can't do BIGINT primary keys
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter_type
    when /mysql/
      execute('ALTER TABLE samples ADD PRIMARY KEY (id);')
      execute('ALTER TABLE samples ' + 
              'MODIFY COLUMN id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;')
    when /postgresql/
      execute('ALTER TABLE samples ADD PRIMARY KEY (id);')
    else
      throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
    end
  end
  
  def down
    drop_table :samples
  end
end
