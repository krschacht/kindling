
class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer  :user_id
      t.integer  :other_id

      t.boolean  :follow
      t.boolean  :friend
      t.boolean  :invited

      t.timestamps
    end

    add_index :relationships, :user_id,  :name => "relationships_user_id"
    add_index :relationships, :other_id, :name => "relationships_other_id"
    add_index :relationships, :follow,   :name => "relationships_follow"
    add_index :relationships, :friend,   :name => "relationships_friend"
    add_index :relationships, :invited,  :name => "relationships_invited"
  end

  def self.down
    drop_table :relationships
  end
end

