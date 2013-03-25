class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.string :name, :null => false
      t.string :sample_type, :null => false
      t.integer :dataset_id, :null => false

      #t.timestamps
    end
   end
end
