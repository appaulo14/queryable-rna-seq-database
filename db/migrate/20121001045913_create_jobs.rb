class CreateJobs < ActiveRecord::Migration
  def up
    create_table :jobs, :id => false do |t|
      #The primary key is different for mysql vs postgresql
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase.to_sym
      case adapter_type
          when :mysql
              #change_column :jobs, :id, 'BIGINT UNSIGNED NOT NULL AUTO_INCREMENT'
              t.column :id, 'BIGINT UNSIGNED NOT NULL AUTO_INCREMENT'
          when :postgresql
              t.column :id, 'bigserial', :null => false
          else
              throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end
      #Add the other columns
      t.string :job_status
      t.string :current_program
      t.string :current_program_status
      t.string :eid_of_owner

      t.timestamps
    end
    execute('ALTER TABLE jobs ADD PRIMARY KEY (id);')
    #Add foreign keys using the foreigner gem
    add_foreign_key(:jobs, :users, column: 'eID_of_owner', primary_key: 'eid')
  end
  
  def down
      drop_table :jobs
  end
end
