class CreateFpkmSamples < ActiveRecord::Migration
  def up
    create_table :fpkm_samples, :id => false do |t|
      #The primary key and some other columns are different 
      # for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        t.column :id, 'BIGINT UNSIGNED', :null => false
        t.column :gene_id, 'BIGINT UNSIGNED'
        t.column :transcript_id, 'BIGINT UNSIGNED'
        t.column :sample_id, 'BIGINT UNSIGNED'
      when /postgresql/
        t.column :id, 'bigserial', :null => false, :unique => true
        t.column :gene_id, 'BIGINT'
        t.column :transcript_id, 'BIGINT'
        t.column :sample_id, 'BIGINT', :null => false
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end
      t.decimal :fpkm, :null => false
      t.decimal :fpkm_hi
      t.decimal :fpkm_lo
      t.string  :status

      #t.timestamps
    end
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
