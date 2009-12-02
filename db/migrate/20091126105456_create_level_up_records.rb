class CreateLevelUpRecords < ActiveRecord::Migration
  def self.up
    create_table :level_up_records do |t|
      t.integer :level_id, :null => false
      t.integer :person_id, :null => false

      t.timestamps
    end

    add_index :level_up_records, :level_id
    add_index :level_up_records, :person_id

  end

  def self.down
    drop_table :level_up_records
  end
end
