
class Post < ActiveRecord::Base

  belongs_to :author,   :class_name => 'User'
  belongs_to :postable, :polymorphic => true

  validates_presence_of :postable_id, :postable_type, :author_id, :facebook_id, :title, :body

  before_validation :update_facebook_id, :update_title

  after_create :update_postable

  def author
    User.find(self.author_id)
  end

  def update_facebook_id
    if author && facebook_id != author.facebook_id
      self.facebook_id = author.facebook_id
    end
  end

  def update_title
    if postable && postable.respond_to?( :title )
      self.title ||= postable.title
    end
  end

  def update_postable
    STDERR.puts "Now in Post#update_postable"
    save_postable = false

    STDERR.puts "[Post#update_postable] Checking for :last_post_at"
    if postable.respond_to?( :last_post_at )
      if postable.last_post_at.nil? || postable.last_post_at < created_at
        postable.last_post_at = created_at
        save_postable = true
        STDERR.puts "[Post#update_postable] set save_postable to true"
      end
    end

    STDERR.puts "[Post#update_postable] Checking for :last_post_author_id"
    if postable.respond_to?( :last_post_author_id )
      if postable.last_post_author_id != author_id
        postable.last_post_author_id = author_id
        save_postable = true
        STDERR.puts "[Post#update_postable] set save_postable to true"
      end
    end

    STDERR.puts "[Post#update_postable] Checking for :post_count"
    if postable.respond_to?( :post_count )
      postable.post_count += 1
      save_postable = true
      STDERR.puts "[Post#update_postable] set save_postable to true"
    end

    STDERR.puts "[Post#update_postable] About to save"
    begin
      postable.save! if save_postable
    rescue Exception => exception
      STDERR.puts exception.inspect
      STDERR.puts exception.message
      STDERR.puts exception.backtrace
    end
  end

  def trimmed_title
    title.length > 30 ? "#{title[0..30]}..." : title
  end

end

