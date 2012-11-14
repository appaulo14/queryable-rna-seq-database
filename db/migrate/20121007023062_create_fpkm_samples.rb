class CreateFpkmSamples < ActiveRecord::Migration
  def up
    create_table :fpkm_samples do |t|
      t.integer :sample_number, :limit=>2
      t.double :q_FPKM
      t.double :q_FPKM_hi
      t.double :q_FPKM_lo
      t.string :q_status
      t.integer :gene_id
      t.integer :transcript_id

      t.timestamps
    end
    execute('ALTER TABLE fpkm_samples ADD PRIMARY KEY (sample_number,gene_id,transcript_id);')
  end
  
  def down
      drop_table :fpkm_samples
  end
end
