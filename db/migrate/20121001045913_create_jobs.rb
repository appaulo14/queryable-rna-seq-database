class CreateJobs < ActiveRecord::Migration
  def up
    create_table :jobs do |t|
      t.string :job_status
      t.string :current_program
      t.string :current_program_status
      t.string :eID_of_owner

      t.timestamps
    end
    adapter_type = ActiveRecord::Base.connection.adapter_name.downcase.to_sym
    case adapter_type
        when :mysql
            change_column :jobs, :id, 'BIGINT UNSIGNED NOT NULL AUTO_INCREMENT'
        when :postgresql
            change_column :jobs, :id, 'bigserial'
        else
            throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
    end

  end
  
  def down
      drop_table :jobs
  end
end
