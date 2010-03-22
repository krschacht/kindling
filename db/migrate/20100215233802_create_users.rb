class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|

      t.integer  :facebook_id,              :limit => 8
      t.string   :session_id
      t.integer  :tag_id,                   :default => 1
      t.string   :install_source,           :default => nil

      t.string   :email,                    :default => nil
      t.boolean  :fan,                      :default => false
      t.boolean  :publish_permission,       :default => false
      t.boolean  :offline_permission,       :default => false
      
      t.integer  :currency,                 :default => 0
      t.integer  :premium_currency,         :default => 0
      t.integer  :total_premium_purchased,  :default => 0
      t.integer  :total_dollars_spent,      :default => 0

      t.integer  :admin_level,              :default => 0

      t.integer  :plays_today,              :default => 0
      t.integer  :total_plays,              :default => 0
      t.string   :last_visit_source,        :default => nil
      t.integer  :consecutive_daily_visits, :default => 0

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
