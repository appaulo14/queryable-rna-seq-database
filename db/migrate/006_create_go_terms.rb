class CreateGoTerms < ActiveRecord::Migration
  def up
    create_table :go_terms, :id => false do |t|
      t.string :id, :null => false
      t.string :term, :null => false

      #t.timestamps
    end
    
    #This is a workaround because rails can't do string primary keys 
    #   by default
    execute('ALTER TABLE go_terms ADD PRIMARY KEY (id);')
  end
  
  def down
      drop_table :go_terms
  end
end
