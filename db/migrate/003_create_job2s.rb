class CreateJob2s < ActiveRecord::Migration
    def up
        create_table :job2s, :id => false do |t|
            adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
            case adapter_type
            when /mysql/
                t.column :id, 'BIGINT UNSIGNED', :null => false
            when /postgresql/
                t.column :id, 'bigserial', :null => false
            else
                throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
            end
            t.string :eid_of_owner
            t.string :current_program_display_name
            t.string :workflow
            t.string :current_step
            t.string :next_step
            t.integer :number_of_samples

            t.timestamps
        end
        #Add primary key using execute statement because
        #   rails can't do non-integer primary keys
        adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
        case adapter_type
        when /mysql/
            execute('ALTER TABLE job2s ADD PRIMARY KEY (id);')
            execute('ALTER TABLE job2s MODIFY COLUMN id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;')
        when /postgresql/
            execute('ALTER TABLE job2s ADD PRIMARY KEY (id);')
        else
            throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
        end
    end
    
    def down
        drop_table :job2s
    end
end
