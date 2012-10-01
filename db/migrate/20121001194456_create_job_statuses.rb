class CreateJobStatuses < ActiveRecord::Migration
    def up
        create_table :job_statuses, :id => false do |t|
            t.string :name, :null => false
            t.string :description, :null => false

            t.timestamps
        end
        #Add primary key using execute statement because
        #   rails can't do non-integer primary keys
        execute('ALTER TABLE job_statuses ADD PRIMARY KEY (name);')
    end

    def down
        drop_table :name
    end
end
