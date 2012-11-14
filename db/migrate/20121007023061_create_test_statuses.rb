class CreateTestStatuses < ActiveRecord::Migration
  def up
    create_table :test_statuses, :id => false do |t|
      t.string :name, :null=>false
      t.text :description

      t.timestamps
    end
    execute('ALTER TABLE test_statuses ADD PRIMARY KEY (name);')
  end
  
  def down
      drop-table :test_statuses
  end
end
