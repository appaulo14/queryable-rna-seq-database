class CreateJobs < ActiveRecord::Migration
    def up
        create_table :jobs, :id => false do |t|
            #The primary key is different for mysql vs postgresql
            adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
            case adapter_type
            when /mysql/
                t.column :id, 'BIGINT UNSIGNED', :null => false
            when /postgresql/
                t.column :id, 'bigserial', :null => false
            else
                throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
            end
            #Add the other columns
            t.string :current_job_status, :null => false
            t.string :current_program_status, :null => false
            t.string :eid_of_owner, :null => false
            t.integer :workflow_step_id, :null => false

            t.timestamps
        end
        #Add primary key using execute statement because
        #   rails can't do non-integer primary keys
        adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
        case adapter_type
        when /mysql/
            execute('ALTER TABLE jobs ADD PRIMARY KEY (id);')
            execute('ALTER TABLE jobs MODIFY COLUMN id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;')
        when /postgresql/
            execute('ALTER TABLE jobs ADD PRIMARY KEY (id);')
        else
            throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
        end
        #Add foreign keys. The SQL is the same for both postgresql and mysql
        execute("ALTER TABLE jobs ADD CONSTRAINT users_fk FOREIGN KEY (eid_of_owner) REFERENCES users (eid) ON UPDATE CASCADE ON DELETE RESTRICT;")
        execute("ALTER TABLE jobs ADD CONSTRAINT job_statuses_fk FOREIGN KEY (current_job_status) REFERENCES job_statuses (name) ON UPDATE CASCADE ON DELETE RESTRICT;")
        execute("ALTER TABLE jobs ADD CONSTRAINT program_statuses_fk FOREIGN KEY (current_program_status) REFERENCES program_statuses (internal_name) ON UPDATE CASCADE ON DELETE RESTRICT;")
        execute("ALTER TABLE jobs ADD CONSTRAINT workflow_steps_fk FOREIGN KEY (workflow_step_id) REFERENCES workflow_steps (id) ON UPDATE CASCADE ON DELETE RESTRICT;")
    end

    def down
        drop_table :jobs
    end
end
