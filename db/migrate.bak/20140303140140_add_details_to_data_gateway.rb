class AddDetailsToDataGateway < ActiveRecord::Migration
  def change
    add_column :data_gateway, :flag_broadcaster, :boolean
    add_column :data_gateway, :website, :string
    add_column :data_gateway, :data_entryway_id, :integer
  end
end
