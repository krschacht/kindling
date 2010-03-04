
class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.integer   :user_id
      t.integer   :number_sent

      t.datetime  :created_at
    end

    add_index :invites, :user_id,     :name => "invites_user_id"
    add_index :invites, :number_sent, :name => "invites_number_sent"
    add_index :invites, :created_at,  :name => "invites_created_at"
  end

  def self.down
    drop_table :invites
  end
end

