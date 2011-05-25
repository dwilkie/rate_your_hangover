class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.references :user
      t.references :voteable, :polymorphic => true
      t.timestamps
    end
    add_index :votes, [:user_id, :voteable_id, :voteable_type], :unique => true
  end

  def self.down
    drop_table :votes
  end
end

