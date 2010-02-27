
class Forum < ActiveRecord::Base

  has_many :topics, :order => "sticky desc, last_post_at desc"
  has_many :topics_for_blog, :class_name => "Topic", :order => "sticky desc, created_at desc"
  has_many :topics_for_forum, :class_name => "Topic", :order => "sticky desc, last_post_at desc"

  validates_presence_of :title
  validates_presence_of :description

  def self.find_forums_for_user_in_area( user, area = :help )
    Forum.find( :all,
      :conditions => ["privacy_level <= ? AND area = ?", (user ? user.admin_level : 0), area.to_s],
      :order => "position" )
  end

  def topics_for_mode
    case self.mode
    when "forum"
      Topic.find(:all, :conditions => ["forum_id = ?", self.id], :order => "sticky desc, last_post_at desc")
    when "blog"
      Topic.find(:all, :conditions => ["forum_id = ?", self.id], :order => "sticky desc, created_at desc")
    end
  end

  def mode_is
    mode.to_sym
  end

  def area_is
    area.to_sym
  end

  def post_allowed_for_user?( user )
    case self.mode_is
    when :forum
      true
    when :blog
      user && user.moderator?
    end
  end

  def trimmed_title
    title.length > 30 ? "#{title[0..30]}..." : title
  end

  def private?
    privacy_level && privacy_level > 0
  end

end

