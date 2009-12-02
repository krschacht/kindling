class CreateLevels < ActiveRecord::Migration
  def self.up
    create_table :levels do |t|
      t.integer :number, :default => 1, :null => false
      t.string :name, :null => false
      t.text :description

      t.timestamps
    end

    add_index :levels, :number
    add_index :levels, :name
  end

  def self.down
    drop_table :levels
  end
end
