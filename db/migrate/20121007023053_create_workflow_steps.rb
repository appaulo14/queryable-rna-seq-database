class CreateWorkflowSteps < ActiveRecord::Migration
  def change
    create_table :workflow_steps do |t|
      t.string :workflows_id
      t.string :programs_internal_name
      t.integer :step

      t.timestamps
    end
  end
end
