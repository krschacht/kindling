class CreateAccessoryTypes < ActiveRecord::Migration
  def self.up
    create_table :accessory_types do |t|
      t.integer :category_id, :null => false
      t.string :name, :null => false
      t.string :image_file_name, :null => false
      t.integer :purchase_price, :null => false

      t.timestamps
    end

    add_index :accessory_types, :category_id
    add_index :accessory_types, :name
    add_index :accessory_types, :image_file_name
    add_index :accessory_types, :purchase_price
  end

  def self.down
    drop_table :accessory_types
  end
end
