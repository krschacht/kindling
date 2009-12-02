class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name, :null => false
      t.boolean :currently_active, :default => true, :null => false

      t.timestamps
    end

    add_index :categories, :name
    add_index :categories, :currently_active
  end

  def self.down
    drop_table :categories
  end
end
