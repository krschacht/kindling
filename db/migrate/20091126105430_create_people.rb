class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.integer :facebook_id, :null => false
      t.integer :level_id, :null => false
      t.integer :account_balance, :default => 0, :null => false
      t.integer :premium_account_balance, :default => 0, :null => false
      t.integer :points, :default => 0, :null => false
      t.timestamp :deleted_at, :default => nil

      t.timestamps
    end

    add_index :people, :facebook_id
    add_index :people, :level_id
    add_index :people, :account_balance
    add_index :people, :premium_account_balance
    add_index :people, :points
    add_index :people, :deleted_at
  end

  def self.down
    drop_table :people
  end
end
