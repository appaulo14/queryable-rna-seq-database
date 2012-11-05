class CreateProgramStatuses < ActiveRecord::Migration
    def up
        create_table :program_statuses, :id => false do |t|
            t.string :internal_name, :null => false
            t.string :display_name, :null => false

            t.timestamps
        end
        #Add primary key using execute statement because
        #   rails can't do non-integer primary keys
        execute('ALTER TABLE program_statuses ADD PRIMARY KEY (internal_name);')
    end

    def down
        drop_table :program_statuses
    end
end
