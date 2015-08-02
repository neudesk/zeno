class AddAffiliateToUsers < ActiveRecord::Migration
  def change
    add_column :sys_user, :affiliate, :string
  end
end
