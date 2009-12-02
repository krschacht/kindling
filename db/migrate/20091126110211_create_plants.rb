class CreatePlants < ActiveRecord::Migration
  def self.up
    create_table :plants do |t|
      t.integer :plant_type_id, :null => false
      t.integer :garden_id, :null => false
      t.integer :sender_id, :null => false
      t.timestamp :sold_at, :null => false
      t.integer :hydration_level, :default => 0, :null => false
      t.integer :orientation, :default => 0, :null => false
      t.integer :scale, :default => 1, :null => false
      t.integer :xcor, :null => false
      t.integer :ycor, :null => false
      t.integer :zcor, :default => 0, :null => false

      t.timestamps
    end

    add_index :plants, :plant_type_id
    add_index :plants, :garden_id
    add_index :plants, :sender_id
    add_index :plants, :sold_at
    add_index :plants, :hydration_level
    add_index :plants, :orientation
    add_index :plants, :scale
    add_index :plants, :xcor
    add_index :plants, :ycor
    add_index :plants, :zcor
  end

  def self.down
    drop_table :plants
  end
end
