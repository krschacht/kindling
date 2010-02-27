
class Topic < ActiveRecord::Base

  belongs_to :author, :class_name => 'User'
  belongs_to :last_post_author, :class_name => 'User'
  belongs_to :forum

  has_many :posts, :as => :postable, :order => "created_at"

  validates_presence_of :author_id, :facebook_id, :forum_id

  before_validation :update_facebook_id

  after_create :update_forum_topic_count

  def posts_after( date )
    Post.find(:all, :conditions => ["postable_id = ? AND created_at >= ?", self.id, date.yesterday], :order => "created_at")
  end

  def update_facebook_id
    if author && facebook_id != author.facebook_id
      self.facebook_id = author.facebook_id
    end
  end

  def update_forum_topic_count
    forum.topic_count += 1
    forum.save
  end

  def merge_into( surviving_topic )
    unless surviving_topic.is_a? Topic
      surviving_topic = Topic.find( surviving_topic )
    end

    return false  unless surviving_topic
    return false  if self.id == surviving_topic.id  # can't merge into itself

    posts_added = 0

    self.posts.each do |p|
      p.postable_id = surviving_topic.id
      p.save

      posts_added += 1
    end

    surviving_topic.post_count += posts_added
    surviving_topic.save

    surviving_topic.reload
    surviving_topic.last_post_author = surviving_topic.posts.last.author
    surviving_topic.last_post_at = surviving_topic.posts.last.created_at

    surviving_topic.save

    self.delete
  end

  def trimmed_title
    title.length > 30 ? "#{title[0..30]}..." : title
  end

  def sticky?
    self.sticky
  end

  def locked?
    self.locked
  end

  def flagged?
    self.flagged
  end

  def flaggable?
    Time.now > self.created_at + 24.hours
  end

  def stick
    self.sticky = 1
    save
  end

  def unstick
    self.sticky = 0
    save
  end

  def lock
    self.locked = 1
    save
  end

  def unlock
    self.locked = 0
    save
  end

  def flag
    self.flagged = 1
    save
  end

  def unflag
    self.flagged = 0
    save
  end

end

