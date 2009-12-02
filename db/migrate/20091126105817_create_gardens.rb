class CreateGardens < ActiveRecord::Migration
  def self.up
    create_table :gardens do |t|
      t.integer :scene_id, :null => false
      t.integer :owner_id, :null => false
      t.integer :creator_id, :null => false
      t.text :description

      t.timestamps
    end

    add_index :gardens, :scene_id
    add_index :gardens, :owner_id
    add_index :gardens, :creator_id
  end

  def self.down
    drop_table :gardens
  end
end
