class CreateFpkmSamples < ActiveRecord::Migration
  def change
    create_table :fpkm_samples do |t|
      t.integer :sample_number
      t.double :q_FPKM
      t.double :q_FPKM_hi
      t.double :q_FPKM_lo
      t.string :q_status
      t.integer :gene_id
      t.integer :transcript_id

      t.timestamps
    end
  end
end
