class CreatePremiumTransactions < ActiveRecord::Migration
  def self.up
    create_table :premium_transactions do |t|

      t.integer     :user_id

      t.integer     :change_amount
      t.integer     :before_amount
      t.integer     :after_amount

      t.string      :type

      t.string      :item_id
      t.integer     :item_quantity

      t.integer     :total_plays
#     t.integer     :level

      t.timestamps
    end
    
    add_index :premium_transactions, :user_id, 
      :name => "premium_transactions_user_id"

    add_index :premium_transactions, :created_at,
      :name => "premium_transactions_created_at"
  end

  def self.down
    drop_table :premium_transactions
  end
end
