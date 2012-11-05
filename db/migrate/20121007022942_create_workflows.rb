class CreateWorkflows < ActiveRecord::Migration
    def change
        create_table :workflows do |t|
            t.string :display_name

            t.timestamps
        end
    end
end
