class CreateGoats < ActiveRecord::Migration
  def change
    create_table :goats do |t|
      t.string :name

      t.timestamps
    end
  end
end
