class CreateAggregateCustom < ActiveRecord::Migration
  def change
    create_table :aggregate_custom do |t|
      t.belongs_to :user
      t.integer :removable_id
      t.string :removable_type
      t.boolean :remove_children, default: false

      t.timestamps
    end
    add_index :aggregate_custom, :user_id
    add_index :aggregate_custom, :removable_id
    add_index :aggregate_custom, :removable_type
    add_index :aggregate_custom, [:removable_id, :removable_type]
  end
end
