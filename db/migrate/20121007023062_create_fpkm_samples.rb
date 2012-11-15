class CreateFpkmSamples < ActiveRecord::Migration
  def up
    create_table :fpkm_samples, :id => false do |t|
      t.integer :sample_number, :limit=>2, :null => false
      t.decimal :q_FPKM, :null=>false
      t.decimal :q_FPKM_hi, :null=>false
      t.decimal :q_FPKM_lo, :null=>false
      t.string :q_status, :null=>false
      t.integer :transcript_id, :null=>false

      t.timestamps
    end
    execute('ALTER TABLE fpkm_samples ADD PRIMARY KEY (sample_number,transcript_id);')
  end
  
  def down
      drop_table :fpkm_samples
  end
end
