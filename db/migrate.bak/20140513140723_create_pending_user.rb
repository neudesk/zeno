class CreatePendingUser < ActiveRecord::Migration
  def change
    create_table :pending_users do |t|
      t.string :station_name
      t.string :company_name
      t.string :streaming_url
      t.string :website
      t.string :genre
      t.string :language
      t.string :name
      t.string :email
      t.string :phone
      t.string :facebook
      t.string :twitter
      t.string :address
      t.string :city
      t.string :state
      t.string :country

      t.timestamps
    end
  end
end
