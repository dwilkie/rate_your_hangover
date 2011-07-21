class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.text       :message
      t.datetime   :read_at
      t.references :user
      t.timestamps
    end
  end
end

