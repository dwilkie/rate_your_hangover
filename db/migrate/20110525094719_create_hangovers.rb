class CreateHangovers < ActiveRecord::Migration
  def self.up
    create_table :hangovers do |t|
      t.string     :title
      t.references :user
      t.integer    :votes_count, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :hangovers
  end
end

