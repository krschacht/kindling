class CreateForums < ActiveRecord::Migration
  def self.up

    create_table "forums", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "position"
      t.integer  "topic_count",   :default => 0
      t.integer  "privacy_level", :default => 0
      t.string   "area",          :default => "help"
      t.string   "entity",        :default => "topic"
      t.string   "mode",          :default => "forum"
    end

    create_table "topics", :force => true do |t|
      t.string   "title"
      t.integer  "author_id"
      t.integer  "facebook_id"
      t.integer  "forum_id"
      t.datetime "last_post_at"
      t.integer  "post_count",          :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "locked",              :default => false
      t.boolean  "sticky",              :default => false
      t.boolean  "flagged",             :default => false
      t.integer  "last_post_author_id"
    end

    add_index "topics", ["author_id"], :name => "topics_author_id"
    add_index "topics", ["created_at"], :name => "topics_created_at"
    add_index "topics", ["forum_id"], :name => "topics_forum_id"
    add_index "topics", ["last_post_at"], :name => "topics_last_post_at"

    create_table "posts", :force => true do |t|
      t.integer  "postable_id"
      t.string   "postable_type"
      t.integer  "author_id"
      t.integer  "facebook_id"
      t.string   "title"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "browser"
    end

    add_index "posts", ["author_id"], :name => "posts_author_id"
    add_index "posts", ["created_at"], :name => "posts_created_at"
    add_index "posts", ["postable_type", "postable_id"], :name => "posts_type_id"





  end

  def self.down
  end
end
