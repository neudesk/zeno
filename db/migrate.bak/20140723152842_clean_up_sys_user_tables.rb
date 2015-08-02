class CleanUpSysUserTables < ActiveRecord::Migration
  def change
    remove_column :sys_user, :facebook
    remove_column :sys_user, :twitter
    remove_column :sys_user, :rca
    remove_column :sys_user, :station_name
    remove_column :sys_user, :streaming_url
    remove_column :sys_user, :website
    remove_column :sys_user, :language
    remove_column :sys_user, :genre
    remove_column :sys_user, :affiliate
    remove_column :sys_user, :on_air_schedule

    add_column :sys_user, :signup_facebook, :string
    add_column :sys_user, :signup_twitter, :string
    add_column :sys_user, :signup_rca, :string
    add_column :sys_user, :signup_station_name, :string
    add_column :sys_user, :signup_streaming_url, :string
    add_column :sys_user, :signup_website, :string
    add_column :sys_user, :signup_language, :string
    add_column :sys_user, :signup_genre, :string
    add_column :sys_user, :signup_affiliate, :string
    add_column :sys_user, :signup_on_air_schedule, :string
    
  end
end
