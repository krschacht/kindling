class CreateFaqs < ActiveRecord::Migration
  def self.up
    create_table "faqs", :force => true do |t|
      t.text   "question"
      t.text   "answer"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
  end
end
