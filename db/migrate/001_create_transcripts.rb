class CreateTranscripts < ActiveRecord::Migration
  def up
    create_table :transcripts, :id => false do |t|
      #The primary key and some other columns are different for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        t.column :id, 'BIGINT UNSIGNED', :null => false
        t.column :dataset_id, 'BIGINT UNSIGNED', :null => false
        t.column :gene_id,'BIGINT UNSIGNED'
      when /postgresql/
        t.column :id, 'bigserial', :null => false, :unique => true
        t.column :dataset_id, 'BIGINT', :null => false
        t.column :gene_id,'BIGINT'
      else
        throw NotImplementedError.new("Unsupported adapter '#{adapter_type}'")
      end
      #Add the other columns
      t.string :name_from_program, :null => false
      

      #t.timestamps
    end
    #Add primary key using execute statement because
    #   rails can't do non-integer primary keys
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
    case adapter_type
    when /mysql/
      execute('ALTER TABLE transcripts ADD PRIMARY KEY (id);')
      execute('ALTER TABLE transcripts MODIFY COLUMN id BIGINT ' +
              'UNSIGNED NOT NULL AUTO_INCREMENT;')
    when /postgresql/
      execute('ALTER TABLE transcripts ADD PRIMARY KEY (id);')
    else
      throw NotImplementedError.new("Unsupported adapter '#{adapter_type}'")
    end
  end
  
  def down
    drop_table :transcripts
  end
end
