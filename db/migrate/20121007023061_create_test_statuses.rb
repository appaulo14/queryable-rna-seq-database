class CreateTestStatuses < ActiveRecord::Migration
  def change
    create_table :test_statuses do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
