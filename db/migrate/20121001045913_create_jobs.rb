class CreateJobs < ActiveRecord::Migration
  def up
    create_table :jobs, :primary_key => false do |t|
      t.string :job_status
      t.string :current_program
      t.string :current_program_status
      t.string :eID_of_owner

      t.timestamps
    end
    #Add foreign keys using the foreigner gem
    change_column :jobs, :job_status, :primary_key
    #add_foreign_key(:jobs, :users, column: 'eID_of_owner', primary_key: 'eID')
    #The primary key is different for mysql vs postgresql
#     adapter_type = ActiveRecord::Base.connection.adapter_name.downcase.to_sym
#     case adapter_type
#         when :mysql
#             change_column :jobs, :id, 'BIGINT UNSIGNED NOT NULL AUTO_INCREMENT'
#         when :postgresql
#             change_column :jobs, :id, 'BIGSERIAL'
#         else
#             throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
#     end
  end
  
  def down
      drop_table :jobs
  end
end
