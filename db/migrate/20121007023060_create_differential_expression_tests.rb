class CreateDifferentialExpressionTests < ActiveRecord::Migration
  def change
    create_table :differential_expression_tests do |t|
      t.string :sample1
      t.string :sample2
      t.string :test_status_name
      t.double :FPKMx
      t.double :FPKMy
      t.double :log2_y_over_x
      t.double :test_stat
      t.double :p_value
      t.double :q_value
      t.boolean :significant?

      t.timestamps
    end
  end
end
