class CreateAccessories < ActiveRecord::Migration
  def self.up
    create_table :accessories do |t|
      t.integer :accessory_type_id, :null => false
      t.integer :garden_id, :null => false
      t.integer :orientation, :default => 0, :null => false
      t.integer :sender_id, :null => false
      t.integer :scale, :default => 1, :null => false
      t.integer :xcor, :null => false
      t.integer :ycor, :null => false
      t.integer :zcor, :default => 0, :null => false

      t.timestamps
    end

    add_index :accessories, :accessory_type_id
    add_index :accessories, :garden_id
    add_index :accessories, :sender_id
    add_index :accessories, :orientation
    add_index :accessories, :scale
    add_index :accessories, :xcor
    add_index :accessories, :ycor
    add_index :accessories, :zcor


  end

  def self.down
    drop_table :accessories
  end
end
