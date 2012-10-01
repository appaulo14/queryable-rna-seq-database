class CreateUsers < ActiveRecord::Migration
    #NOTE: I used the up and down methods instead of just the change method 
    #   because using only the change method resulted in an irrevisible 
    #   migation exception
  
  def up
    create_table(:users, :id => false) do |t|
      t.string :eid, :null => false
      t.string :email, :null => false

      t.timestamps
    end
    #change_column :users, :eID, :string
    execute('ALTER TABLE users ADD PRIMARY KEY (eid);')
    #add_index :users, :email, :unique => true
  end
  
  def down
      drop_table :users
  end
  
  def down
      drop_table :users
  end
end