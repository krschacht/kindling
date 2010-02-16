class CreateGambitPostbacks < ActiveRecord::Migration
  def self.up
    create_table :gambit_postbacks do |t|

      t.integer     :premium_transaction_id

      t.integer     :ocid
      t.integer     :uid
      t.integer     :amount
      t.integer     :time

      t.integer     :oid
      t.string      :title

      t.string      :subid1
      t.string      :subid2
      t.string      :subid3

      t.timestamps
    end

    add_index :gambit_postbacks,     :premium_transaction_id,
      :name => "gambit_postbacks_premium_transaction_id"

    add_index :gambit_postbacks,     :uid,
      :name => "gambit_postbacks_uid"

    add_index :gambit_postbacks,     :created_at,
      :name => "gambit_postbacks_created_at"

  end

  def self.down
    drop_table :gambit_postbacks
  end
end
