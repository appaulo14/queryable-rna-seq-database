class CreateGeneHasGoTerm < ActiveRecord::Migration
  def up
    create_table :gene_has_go_terms, :id => false do |t|
      t.integer :gene_id
      t.string :go_term_id

      t.timestamps
    end
  end
  
  def down
      drop_table :gene_has_go_terms
  end
end
