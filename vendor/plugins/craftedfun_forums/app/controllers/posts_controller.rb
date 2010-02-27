
class PostsController < ApplicationController

  unloadable

  skip_before_filter :ensure_authenticated_to_facebook, :only => :create
  skip_before_filter :ensure_application_is_installed_by_facebook_user, :only => :create
  skip_before_filter :set_facebook_session, :only => :create
  prepend_before_filter :get_rails_session_from_param, :only => :create

  def index
    unless current_user.moderator?
      redirect_to "/forums"
      return
    end

    @posts = Post.paginate(
                           :page     => params[:page],
                           :per_page => 10,
                           :order    => 'created_at desc'  )
  end

  def show
    @post = Post.find( params[:id] )

    if @post.postable.kind_of?( Topic )
      @topic = @post.postable
      @forum = @topic.forum

      if @forum.privacy_level > current_user.admin_level
        redirect_to "/forums"
        return
      end
    end

    @page_title = "Editing Post"
    @page_title += " under Topic: #{@topic.title}" if @topic
  end

  def edit

    if params[:id] && params[:post][:body]
      post = Post.find( params[:id] )

      if post && ( current_user.moderator? || ( current_user == post.author && post.created_at + 1.hour > Time.now ) )
        post.body = params[:post][:body]
        if post.save
          expire_fragment( "topic/#{post.postable_id}" )

          flash[:success_msg] = "Edits have been saved."
        else
          flash[:error_msg] = "Edits could not be saved"
        end
      else
        flash[:error_msg] = "Edits could not be saved"
      end
    else
      flash[:error_msg] = "Edits could not be saved"
    end

    redirect_to topic_url( post.postable_id )
  end

  def create
    if params[:post]
      if params[:topic_id]
        postable = Topic.find( params[:topic_id] )
      end

      if postable
        p = Post.create( :author   => current_user,
                         :body     => params[:post][:body],
                         :browser  => request.env['HTTP_USER_AGENT'] + " Flash Version: " + params[:flash_version],
                         :postable => postable )


        expire_fragment( "topic/#{postable.id}" )

        if request.xhr?
          render :json => {
            :post_html  => render_to_string( :partial => 'posts/post', :object  => p ),
            :post_count => "#{postable.post_count} posts",
            :topic_id => params[:topic_id]
          }.to_json

          return
        end

        redirect_to( "#{topic_url( postable )}#post#{p.id}" )
        return
      end
    end

    flash[:error] = "Unable to post message"
    redirect_to( request.request_uri )
  end

  private

  def require_moderator
    unless current_user && current_user.moderator?
      render :text => "<p>You don't have permission to do that!</p>"
    end
  end

end

