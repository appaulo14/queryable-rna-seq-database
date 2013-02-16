class CreateTranscriptHasGoTerm < ActiveRecord::Migration
  def up
    create_table :transcript_has_go_terms, :id => false do |t|
      t.integer :transcript_id, :null => false
      t.string :go_term_id, :null => false

      #t.timestamps
    end
    #This is a workaround because rails can't do string or multiple 
    #   primary keys by default
    execute('ALTER TABLE transcript_has_go_terms ' +
            'ADD PRIMARY KEY (transcript_id,go_term_id);')
  end
  
  def down
      drop_table :transcript_has_go_terms
  end
end
