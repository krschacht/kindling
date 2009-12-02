class CreateVisits < ActiveRecord::Migration
  def self.up
    create_table :visits do |t|
      t.integer :garden_id, :null => true
      t.integer :person_id, :null => true

      t.timestamps
    end

    add_index :visits, :garden_id
    add_index :visits, :person_id
  end

  def self.down
    drop_table :visits
  end
end
