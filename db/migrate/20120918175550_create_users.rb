class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users, :primary_key => 'eID') do |t|
      t.string :eID
      t.string :email, :null => false

      t.timestamps
    end
    add_index :users, :email, :unique => true
  end
end
