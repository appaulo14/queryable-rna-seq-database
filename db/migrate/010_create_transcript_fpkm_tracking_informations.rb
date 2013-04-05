class CreateTranscriptFpkmTrackingInformations < ActiveRecord::Migration
  def up
    create_table :transcript_fpkm_tracking_informations, :id => false do |t|
      #The primary key and some other columns are different for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        t.column :transcript_id,'BIGINT UNSIGNED', :null => false
      when /postgresql/
        t.column :transcript_id,'BIGINT', :null => false
      else
        throw NotImplementedError.new("Unsupported adapter '#{adapter_type}'")
      end
      #Add the other columns
      t.string :class_code, :null => false
      t.integer :length, :null => false
      t.string :coverage

      #t.timestamps
    end
    #Add indexes
    add_index :transcript_fpkm_tracking_informations, :transcript_id
    #Add primary key using execute statement because
    #   rails can't do non-integer primary keys
    execute('ALTER TABLE transcript_fpkm_tracking_informations ' +
            'ADD PRIMARY KEY (transcript_id);')
  end
  
  def down
    drop_table :transcript_fpkm_tracking_informations 
  end
end
