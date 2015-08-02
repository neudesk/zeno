class CreateDataGatewayNote < ActiveRecord::Migration
  def self.up
    create_table :data_gateway_note do |t|
      t.string :user_id, null: true
      t.string :gateway_id, null: true
      t.text :note, null: false
      t.boolean :is_deleted, default: false
      t.string
      t.timestamps
    end
  end

  def self.down
    drop_table :data_gateway_note
  end

end
