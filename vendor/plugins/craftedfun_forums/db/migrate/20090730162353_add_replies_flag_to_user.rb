class AddRepliesFlagToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :new_replies, :boolean, :default => false
  end

  def self.down
    remove_column :users, :new_replies
  end
end
