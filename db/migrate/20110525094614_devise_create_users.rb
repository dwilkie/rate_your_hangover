class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => true
      t.string       :display_name
      t.recoverable
      t.rememberable
      t.trackable

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :current_sign_in_ip
    add_index :users, :last_sign_in_ip

  end

  def self.down
    drop_table :users
  end
end

