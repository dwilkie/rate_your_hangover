class CreateHangovers < ActiveRecord::Migration
  def self.up
    create_table :hangovers do |t|
      t.string     :title
      t.string     :image
      t.references :user
      t.integer    :votes_count, :null => false, :default => 0
      t.timestamps
    end

    add_index :hangovers, :image, :unique => true
  end

  def self.down
    drop_table :hangovers
  end
end

