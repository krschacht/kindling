
class ForumsController < ApplicationController

  unloadable

  def index
    @forums = Forum.find_forums_for_user_in_area( @rails_user, :help )

    if @forums.empty?
      render :text => "Hey, you need to define at least one forum!"
      return
    end

    @num_faq_to_show = 5

    if @rails_user && @rails_user.moderator?
      @flagged_topics = Topic.find( :all,
        :conditions => { :flagged => true },
        :order      => "sticky desc, last_post_at desc",
        :include    => [ :last_post_author, { :posts => :author } ] )
    end

    @page_title = "Help & Discussion Overview"
    render("forums/index_plain", :layout => "unstyled") unless @rails_user
  end

  def show
    @forum = Forum.find( params[:id] )

    if @forum.privacy_level > ( @rails_user ? @rails_user.admin_level : 0 )
      redirect_to "/forums"
      return
    end

    case @forum.mode_is
    when :forum
      @topics = @forum.topics_for_forum.paginate(
        :include  => :last_post_author,
        :page     => params[:page],
        :per_page => 15 )
    when :blog
      @topics = @forum.topics_for_blog.paginate(
        :include  => :last_post_author,
        :page     => params[:page],
        :per_page => 15 )
    end

    @page_title = @forum.title
    render("forums/show_plain", :layout => "unstyled") unless @rails_user
  end

  def show_for_iframe
    @forum = Forum.find( params[:id] )

    @forum = nil if !@forum || @forum.privacy_level > ( @rails_user ? @rails_user.admin_level : 0 )

    render("forums/show_for_iframe", :layout => "plain") if @rails_user
    render("forums/show_plain", :layout => "unstyled") if !@rails_user
  end

  def new
    @forum = Forum.find( params[:id] )
    @hide_topics = true

    @page_title = "Start New #{@forum.entity.titleize} in #{@forum.title}"
    render :template => "/forums/show"
  end

end

