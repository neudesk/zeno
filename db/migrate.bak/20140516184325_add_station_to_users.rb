class AddStationToUsers < ActiveRecord::Migration
  def change
    add_column :sys_user, :rca, :string
    add_column :sys_user, :station_name, :string
    add_column :sys_user, :streaming_url, :string
    add_column :sys_user, :website, :string
    add_column :sys_user, :language, :string
    add_column :sys_user, :genre, :string
  end
end
