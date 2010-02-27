class TopicsController < ApplicationController

  unloadable

  skip_before_filter :ensure_authenticated_to_facebook, :only => :create
  skip_before_filter :ensure_application_is_installed_by_facebook_user, :only => :create
  skip_before_filter :set_facebook_session, :only => :create
  prepend_before_filter :get_rails_session_from_param, :only => :create

  skip_filter   :welcome_check, :only => :show
  skip_filter   :set_back_link

  before_filter :require_moderator,
    :only => [:edit, :move, :lock, :unlock, :stick, :unstick, :unflag]
  before_filter :set_forums,
    :only => [:show, :move, :lock, :unlock, :stick, :unstick, :flag, :unflag]

  def index
    redirect_to "/forums"
  end

  def started_by_user
    @back_link[:name] = "<< Back to Help & Discussion"
    @back_link[:location] = "/forums"

    if params[:id]

      begin
        @user = User.find( params[:id] )

        # current_user.replies_viewed! if @user == current_user

        if @user
          @topics = Topic.find(:all, :conditions => [ "author_id = ?", @user ], :order => "last_post_at DESC").paginate(
            :page     => params[:page],
            :per_page => 15 )
        else
          redirect_to "/forums"
        end
      rescue
        redirect_to "/forums"
      end
    end

    # @page_title = "All Topics Started By #{facebook_session.user.full_name}"
    @page_title = "All Topics Started By the user"
  end

  def posted_in_by_user
    @back_link[:name] = "<< Back to Help & Discussion"
    @back_link[:location] = "/forums"

    if params[:id]

      begin
        @user = User.find( params[:id] )

        if @user
          @topics = Topic.find(:all, :joins => :posts,
                :conditions => [ "posts.author_id = ?", @user ],
                :group => "posts.postable_id",
                :order => "topics.last_post_at DESC").paginate(
            :page     => params[:page],
            :per_page => 15 )
        else
          redirect_to "/forums"
        end
      rescue
        redirect_to "/forums"
      end
    end

    @page_title = "All Topics #{@user.full_name} Posted In"  if @user
  end

  def show
    @topic = Topic.find( params[:id] )
    @forum = @topic.forum

    if @forum.privacy_level > ( current_user ? current_user.admin_level : 0 )
      redirect_to "/forums"
      return
    end

    # current_user.replies_viewed! if current_user && @topic.author == current_user

    unless read_fragment( "topic/#{@topic.id}" ) && current_user
      @posts = @topic.posts.find( :all, :include => :author )
    end

    @page_title = @topic.title

    render("topics/show_plain", :layout => "unstyled") unless current_user
  end

  def create
    if params[:post]
      if params[:forum_id]
        forum = Forum.find( params[:forum_id] )
      end

      if forum
        t, p = nil, nil

        Topic.transaction do
          t = Topic.create!( :author  => current_user,
                             :title   => params[:post][:title],
                             :forum   => forum )

          p = Post.create!( :author   => current_user,
                            :body     => params[:post][:body],
                            :browser  => request.env['HTTP_USER_AGENT'],
                            :postable => t )
        end

        if t && p
          if request.xhr?

            render :text => {
              :topic_html => render_to_string( :partial => 'topics/topic',
                                               :object  => t )
            }.to_json

            return
          end

          redirect_to( "#{topic_url( t )}#post#{p.id}" )
          return
        end
      end
    end

    flash[:error] = "Unable to post message"
    redirect_to( request.request_uri )
  end

  def edit

    if params[:id] && params[:topic][:title] && request.xhr?

      topic = Topic.find( params[:id] )
      # For some reason all the posts have a title as well, not sure why... we won't update that
      topic.title = params[:topic][:title]
      topic.save!

      expire_fragment( "topic/#{topic.id}" )

      if topic

        render :text => {
          :topic_title  => params[:topic][:title],
          :topic_id     => topic.id
        }.to_json

        return
      end
    end

    render :partial => 'topics/admin_controls'
  end

  def merge
    if params[:id] && params[:into_topic_id]
      @topic = Topic.find( params[:id] )
      @topic.merge_into( params[:into_topic_id] )

      @topic.forum.topic_count = @topic.forum.topics.length

      expire_fragment( "topic/#{@topic.id}" )
    end

    @topic = Topic.find( params[:into_topic_id] )
    @topic.forum.topic_count = @topic.forum.topics.length

    expire_fragment( "topic/#{@topic.id}" )

    render :partial => 'topics/admin_controls'
  end

  def move
    if params[:id] && params[:forum_id]
      @topic = Topic.find( params[:id] )

      Forum.transaction do
        @origin = @topic.forum
        @dest = Forum.find( params[:forum_id] )

        @topic.forum = @dest
        @topic.save
      end

      @origin.topic_count = @origin.topics.length
      @origin.save

      @dest.topic_count = @dest.topics.length
      @dest.save
    end

    render :partial => 'topics/admin_controls'
  end

  def lock
    if params[:id]
      @topic = Topic.find( params[:id] )
      @topic.lock
    end

    render :partial => 'topics/admin_controls'
  end

  def unlock
    if params[:id]
      @topic = Topic.find( params[:id] )
      @topic.unlock
    end

    render :partial => 'topics/admin_controls'
  end

  def stick
    if params[:id]
      @topic = Topic.find( params[:id] )
      @topic.stick
    end

    render :partial => 'topics/admin_controls'
  end

  def unstick
    if params[:id]
      @topic = Topic.find( params[:id] )
      @topic.unstick
    end

    render :partial => 'topics/admin_controls'
  end

  def flag
    if params[:id]
      @topic = Topic.find( params[:id] )
      @topic.flag
    end

    render :partial => 'topics/public_controls'
  end

  def unflag
    if params[:id]
      @topic = Topic.find( params[:id] )
      @topic.unflag
    end

    render :partial => 'topics/public_controls'
  end


  private

  def require_moderator
    unless current_user && current_user.moderator?
      render :text => "<p>You don't have permission to do that!</p>"
    end
  end

  def set_forums
    @forums = Forum.find(:all)  if current_user && current_user.moderator?
  end

end

