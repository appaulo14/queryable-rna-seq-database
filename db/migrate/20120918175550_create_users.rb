class CreateUsers < ActiveRecord::Migration
    #NOTE: I used the up and down methods instead of just the change method 
    #   because using only the change method resulted in an irrevisible 
    #   migation exception
  
  def up
    create_table(:users, :primary_key => "eID") do |t|
      t.string :email, :limit => 45, :null => false

      t.timestamps
    end
    change_column :users, :eID, :string, :limit => 45
    add_index :users, :email, :unique => true
  end
  
  def down
      drop_table :users
  end
end
