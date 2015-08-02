class AddAreaCodeToDataListener < ActiveRecord::Migration
  def change
    add_column :data_listener, :area_code, :string
  end
end
