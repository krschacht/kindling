class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer  :facebook_id,      :limit => 8
      t.integer  :currency,         :default => 0
      t.integer  :premium_currency, :default => 0
      t.integer  :admin_level,      :default => 0
      t.string   :install_source,   :default => nil
      t.integer  :total_plays,      :default => 0
      t.datetime :last_played_at
      t.datetime :last_alert_at
      t.datetime :installed_at
      t.datetime :removed_at

      t.timestamps
    end

    add_index :users, :facebook_id
    add_index :users, :total_plays
    add_index :users, :last_played_at
  end

  def self.down
    drop_table :users
  end
end
