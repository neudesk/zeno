class CreateGlobalSetting < ActiveRecord::Migration
  def change
    create_table :global_setting do |t|
      t.string :group
      t.string :name
      t.string :value
      t.timestamps
    end
  end
end
