class CreateBadListener < ActiveRecord::Migration
  def self.up
    create_table :bad_listener do |t|
      t.string :ani_e164, null: false
      t.string :clec, null: true
      t.string :carrier, null: true
      t.string :assigned_clec, null: true
      t.string :gateway_id, null: true
      t.string :assigned_did, null: true
      t.timestamps
    end
  end

  def self.down
    drop_table :bad_listener
  end

end
