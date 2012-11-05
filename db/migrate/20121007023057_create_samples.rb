class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.integer :sample_id
      t.integer :job_id
      t.string :status

      t.timestamps
    end
  end
end
