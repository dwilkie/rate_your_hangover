class CreateHangovers < ActiveRecord::Migration
  def self.up
    create_table :hangovers do |t|
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :hangovers
  end
end

