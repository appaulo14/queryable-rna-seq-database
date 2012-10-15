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
            t.string :eID_of_owner
            t.string :workflow
            t.string :current_step
            t.string :next_step

            t.timestamps
        end
    end
    
    def down
        drop_table :job2s
    end
end
