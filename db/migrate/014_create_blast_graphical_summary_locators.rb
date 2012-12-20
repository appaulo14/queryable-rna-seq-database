class CreateBlastGraphicalSummaryLocators < ActiveRecord::Migration
  def up
    create_table :blast_graphical_summary_locators, :id => false do |t|
      t.string :basename, :null => false
      t.text :html_output_file_path, :null => false
      t.integer :dataset_id, :null => false

      t.timestamps
    end
    #This is a workaround because rails can't do string primary keys 
    #   by default
    execute('ALTER TABLE blast_graphical_summary_locators '+
            'ADD PRIMARY KEY (basename);')
  end
  
  def down
    drop_table :blast_graphical_summary_locators
  end
end
