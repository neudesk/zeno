class CreateAdminDncList < ActiveRecord::Migration
  def change
    create_table :admin_dnc_list do |t|
      t.integer :listener_id
      t.string :phone_number
      t.datetime :created_at

      t.timestamps
    end
  end
end
