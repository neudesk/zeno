class CreateSysUserTags < ActiveRecord::Migration
  def change
    create_table :sys_user_tags do |t|
      t.integer :user_id
      t.string :tag
    end

    create_table :sys_user_countries do |t|
      t.integer :user_id
      t.integer :country_id
    end
  end
end
