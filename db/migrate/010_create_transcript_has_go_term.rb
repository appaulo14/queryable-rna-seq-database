class CreateTranscriptHasGoTerm < ActiveRecord::Migration
  def up
    create_table :transcript_has_go_terms, :id => false do |t|
      t.integer :transcript_id
      t.string :go_term_id

      t.timestamps
    end
  end
  
  def down
      drop_table :transcript_has_go_terms
  end
end
