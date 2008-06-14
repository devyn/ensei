require 'z3'
class CreateUserspaces < ActiveRecord::Migration
  def self.up
    create_table :userspaces do |t|
      t.integer :id, :null => false
      t.integer :user_id, :null => false
      t.text    :contents, :default => Base64.encode64(Z3.new.save)

      t.timestamps
    end
  end

  def self.down
    drop_table :userspaces
  end
end
