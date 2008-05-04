class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :id, :null => false
      t.string :name
      t.string :pass
      t.text :data

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
