class CreateSparechangePostbacks < ActiveRecord::Migration
  def self.up
    create_table :sparechange_postbacks do |t|

      t.integer     :premium_transaction_id

      t.integer     :senderid,         :limit => 20
      t.integer     :points
      t.string      :amount
      t.string      :txid
      t.integer     :appid
      t.integer     :network

      t.timestamps
    end
    
    add_index :sparechange_postbacks,     :premium_transaction_id,
      :name => "sparechange_postbacks_premium_transaction_id"

    add_index :sparechange_postbacks,     :senderid,
      :name => "sparechange_postbacks_senderid"

    add_index :sparechange_postbacks,     :created_at,
      :name => "sparechange_postbacks_created_at"
    
  end

  def self.down
    drop_table :sparechange_postbacks
  end
end
