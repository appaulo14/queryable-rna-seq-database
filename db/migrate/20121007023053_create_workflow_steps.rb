class CreateWorkflowSteps < ActiveRecord::Migration
  def up
    create_table :workflow_steps do |t|
      t.integer :workflow_id
      t.string :program_internal_name
      t.integer :step

      t.timestamps
    end
    execute("ALTER TABLE workflow_steps ADD CONSTRAINT workflows_fk FOREIGN KEY (workflow_id) REFERENCES workflows (id) ON UPDATE CASCADE ON DELETE RESTRICT;")
    execute("ALTER TABLE workflow_steps ADD CONSTRAINT programs_fk FOREIGN KEY (program_internal_name) REFERENCES programs (internal_name) ON UPDATE CASCADE ON DELETE RESTRICT;")
  end
  
  def down
      drop_table :workflow_steps
  end
end
