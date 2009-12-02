class CreateScenes < ActiveRecord::Migration
  def self.up
    create_table :scenes do |t|
      t.string :name, :null => false
      t.string :image_file_name, :null => false

      t.timestamps
    end

    add_index :scenes, :name
  end

  def self.down
    drop_table :scenes
  end
end
