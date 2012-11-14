class CreateGenes < ActiveRecord::Migration
  def change
    create_table :genes do |t|
      t.string :program_id
      t.integer :job_id
      t.integer :differential_expression_test_id

      t.timestamps
    end
  end
end
