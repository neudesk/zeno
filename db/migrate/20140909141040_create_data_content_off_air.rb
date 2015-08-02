class CreateDataContentOffAir < ActiveRecord::Migration
  def change
    create_table :data_content_off_air do |t|
      t.integer :content_id
      t.integer :day
      t.time :time_start
      t.time :time_end
      t.string :stream_url

      t.timestamps
    end
  end
end
