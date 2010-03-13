class CreateVisits < ActiveRecord::Migration
  def self.up
    create_table :visits do |t|
      t.integer     :user_id
      t.date        :date
      t.integer     :plays
    end
  end

  def self.down
    drop_table :visits
  end
end
