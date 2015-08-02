class AddDeviseFieldsToSysUser < ActiveRecord::Migration
  def change
    ## Database authenticatable
      add_column :sys_user, :email, :string, :null => false, :default => ""
      add_column :sys_user, :encrypted_password, :string, :null => false, :default => ""

      ## Recoverable
      add_column   :sys_user, :reset_password_token, :string
      add_column :sys_user, :reset_password_sent_at, :datetime

      ## Rememberable
      add_column :sys_user,:remember_created_at, :datetime

      ## Trackable
      add_column  :sys_user, :sign_in_count, :integer, :default => 0
      add_column :sys_user, :current_sign_in_at, :datetime
      add_column :sys_user, :last_sign_in_at, :datetime
      add_column   :sys_user, :current_sign_in_ip, :string
      add_column   :sys_user, :last_sign_in_ip, :string

      ## Confirmable
      # add_column   :sys_user, :confirmation_token, :string
      # add_column :sys_user, :confirmed_at, :datetime
      # add_column :sys_user, :confirmation_sent_at, :datetime
      # add_column   :sys_user, :unconfirmed_email, :string # Only if using reconfirmable

      ## Lockable
      add_column  :sys_user, :failed_attempts, :integer, :default => 0 # Only if lock strategy is :failed_attempts
      add_column   :sys_user, :unlock_token, :string # Only if unlock strategy is :email or :both
      add_column :sys_user, :locked_at, :datetime

      ## Token authenticatable
      # add_column :sys_user, :authentication_token, :string

      add_column(:sys_user, :created_at, :datetime)
      add_column(:sys_user, :updated_at, :datetime)


      add_index :sys_user, :email,                :unique => true
      add_index :sys_user, :reset_password_token, :unique => true
      # add_index :sys_user, :confirmation_token,   :unique => true
      add_index :sys_user, :unlock_token,         :unique => true
      # add_index :sys_user, :authentication_token, :unique => true


  end
end
