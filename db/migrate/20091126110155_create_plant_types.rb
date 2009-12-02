class CreatePlantTypes < ActiveRecord::Migration
  def self.up
    create_table :plant_types do |t|
      t.integer :category_id, :null => false
      t.string :name, :null => false
      t.string :image_file_name, :null => false
      t.integer :time_to_mature, :null => false
      t.integer :purchase_price, :null => false
      t.integer :sale_price, :null => false

      t.timestamps
    end

    add_index :plant_types, :category_id
    add_index :plant_types, :name
    add_index :plant_types, :time_to_mature
    add_index :plant_types, :purchase_price
    add_index :plant_types, :sale_price
  end

  def self.down
    drop_table :plant_types
  end
end
