class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :title
    end

    create_table :user_tags do |t|
      t.integer :tag_id
      t.integer :user_id
    end

    add_index :user_tags, :tag_id
    add_index :user_tags, :user_id

    remove_column :sys_user, :tags
  end
end
