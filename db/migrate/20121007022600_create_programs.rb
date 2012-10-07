class CreatePrograms < ActiveRecord::Migration
  def up
    create_table :programs, :id => false do |t|
      t.string :internal_name
      t.string :display_name

      t.timestamps
    end
    #Add primary key using execute statement because
    #   rails can't do non-integer primary keys
    execute('ALTER TABLE programs ADD PRIMARY KEY (internal_name);')
  end
  
  def down
      drop_table :programs
  end
end
