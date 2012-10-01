class CreatePrograms < ActiveRecord::Migration
    def up
        create_table :programs, :id => false do |t|
            t.string :name, :null => false
            t.string :description, :null => false

            t.timestamps
        end
        #Add primary key using execute statement because
        #   rails can't do non-integer primary keys
        execute('ALTER TABLE programs ADD PRIMARY KEY (name);')
    end

    def down
        drop_table :programs
    end
end
