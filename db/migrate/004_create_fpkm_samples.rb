class CreateFpkmSamples < ActiveRecord::Migration
  def up
    create_table :fpkm_samples, :id => false do |t|
      #The primary key and some other columns are different 
      # for mysql vs postgresql
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
      t.column :transcript_id, big_int, :null => false
      t.integer :sample_id, :null => false
      t.column :fpkm, double, :null => false
      t.column :fpkm_hi, double, :null => false
      t.column :fpkm_lo, double, :null => false
      t.string  :status, :null => false

      #t.timestamps
    end
    #Add indexes
    add_index :fpkm_samples, :transcript_id
    add_index :fpkm_samples, :sample_id
    #Add primary key using execute statement because
    #   rails can't do BIGINT primary keys
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter_type
    when /mysql/
      execute('ALTER TABLE fpkm_samples ADD PRIMARY KEY (id);')
      execute('ALTER TABLE fpkm_samples ' + 
              'MODIFY COLUMN id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;')
    when /postgresql/
      execute('ALTER TABLE fpkm_samples ADD PRIMARY KEY (id);')
    else
      throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
    end
  end
  
  def down
    drop_table :fpkm_samples
  end
end
