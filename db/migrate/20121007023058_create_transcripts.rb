class CreateTranscripts < ActiveRecord::Migration
  def change
    create_table :transcripts do |t|
      t.string :program_id
      t.string :sequence
      t.integer :differential_expression_test_id
      t.integer :job_id
      t.integer :gene_id

      t.timestamps
    end
  end
end
