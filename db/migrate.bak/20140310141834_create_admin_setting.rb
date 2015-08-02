class CreateAdminSetting < ActiveRecord::Migration
  def change
    create_table :admin_setting do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
