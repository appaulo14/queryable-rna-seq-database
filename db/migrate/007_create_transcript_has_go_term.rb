class CreateTranscriptHasGoTerm < ActiveRecord::Migration
  def up
    create_table :transcript_has_go_terms, :id => false do |t|
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        t.column :transcript_id, 'BIGINT UNSIGNED', :null => false
      when /postgresql/
        t.column :transcript_id, 'BIGINT', :null => false
      else
        throw NotImplementedError.new("Unsupported adapter '#{adapter_type}'")
      end
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
