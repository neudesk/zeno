class AddColumnMetadataToDataGateway < ActiveRecord::Migration

  def self.up
    add_column :data_gateway, :metadata, :string
    add_column :data_gateway, :widget_is_set_up, :boolean, default: false
  end

  def self.down
    remove_column :data_gateway, :metadata
    remove_column :data_gateway, :widget_is_set_up
  end

end
