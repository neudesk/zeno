class CreateOptInList < ActiveRecord::Migration
  def change
    create_table :opt_in_list do |t|
      t.integer :listener_id
      t.integer :ani_e164, :limit => 5

      t.timestamps
    end
  end
end
