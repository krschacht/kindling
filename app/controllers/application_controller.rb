# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all

  ## Authenticaiton
  
  helper_method :actor, :session_key, :session_id, :session_cookie_confirmed?                

  attr_reader   :actor

  before_filter :setup_browser_view, :ensure_installed

                def setup_browser_view
                  set_p3p_header
                  set_ie7_header    
                  check_facebook_logged_out
                  check_session_cookie
                  set_actor
                  update_facebook_session
                end  
  
  ## General app stuff 

  helper_method :action_name_safe
  
  before_filter :update_relationship,
                :update_install,
                :update_install_source,
                :log_user_ids,
                :action_name_safe,
                :select_tab,
	              :invites_sent_msg



  protected

  ### Helper methods

  # Returns the session_key, aka the name of the cookie (or param) that
  # contains the session_id.

  def session_key
    request.session_options[:key]
  end

  def session_id
    request.session_options[:id]
  end

  # Has the session cookie been confirmed?  Most browsers (Safari and IE,
  # for example) delete 3rd party cookies.  We need to confirm that our
  # session cookie has not been deleted after every

  def session_cookie_confirmed?
    session[:confirmed]
  end

  # Is this the first request in a facebook iframe?

  def first_request_in_iframe?
    request_comes_from_facebook? && facebook_params[:in_iframe]
  end

  # This utility method can be used to breakout of the facebook iframe.  This
  # should be used if you want to redirect to a page outside the iframe.

  def breakout_to( url )
    url += (url =~ /\?/) ? '&' : '?'
    url += "forward_counter=" + params[:forward_counter].to_i.to_s

    render :text => %Q(
      <script type="text/javascript">
        top.location.href = '#{url}';
      </script>

      <p>Loading ... </p>
      <p>(if you are stuck <a href="#{url}">click here</a> to continue...)</p>
    )
  end




  ### Filters for Authentication

  # Sets the actor and update the session[:user_id] value.

  def set_actor
    logger.debug "*** set_actor "
    logger.debug "*** #{ @actor ? 'yes' : 'no' } actor "

    if ! @actor && session[:user_id]
      logger.debug "*** no @actor but there is a user_id in session "
      
      @actor = User.find_by_id( session[:user_id] )

      if @actor.nil?
        session[:user_id] = nil
      end

      if facebook_session && @actor &&
         facebook_session.session_key != @actor.session_id

        @actor = nil
        reset_session
      end
    end

    if ! @actor && check_facebook_session
      logger.debug "*** no @actor but there is a facebook session "

      @actor =
        User.for( facebook_session.user, facebook_session )
    end

    # from FB docs: fb_sig_user/fb_sig_canvas_user: The visiting user's ID. 
    # fb_sig_canvas_user is passed if user has not authorized your application, 
    # while fb_sig_user is passed if the user has authorized your application. 
    # When a user first visits an application tab, fb_sig_user and 
    # fb_sig_profile_user are passed, with both set to the profile owner's user ID.

    if request_comes_from_facebook? && ( facebook_params[:user] || facebook_params[:canvas_user] )
      logger.debug "*** request comes from facebook "

      @actor = User.for( facebook_params[:user] || facebook_params[:canvas_user] )
    end

    if @actor && session[:user_id] && 
       @actor.id != session[:user_id] 

      logger.debug "*** yes actor but the actor.id != user_id in session "
       
      session[:user_id] = nil # probably redundant
      reset_session
    end

    if @actor && ! session[:user_id]
      logger.debug "*** yes actor but no user_id in session "
      
      session[:user_id] = @actor.id
    end

    logger.debug "*** #{ @actor ? 'yes' : 'no' } actor "

  end

  # Update the stored facebook_session for actor.

  def update_facebook_session
    logger.debug "*** update_facebook_session "

    if request_comes_from_facebook? && actor
      check_facebook_session

      if facebook_session
        actor.store_facebook_session( facebook_session )
      end
    end
  end

  # This filter checks installed? and breaks out to the facebook install url
  # if the user has not installed the app.  The user will the be redirected
  # back to the requested page.

  def ensure_installed
    
    logger.debug "*** ensure_installed "
    
    if ! actor or ! actor.installed?
  
      install_source = params[:install_source] || params[:s]
      forward_counter = params[:forward_counter].to_i
          
      breakout_to( new_facebook_session.install_url(
        :next => url_for( :canvas           => true, 
                          :fb               => false, 
                          :r                => params[:r],
                          :s                => install_source,
                          :forward_counter  => forward_counter ) ) )
      return false
    end
  end

  # This filter ensures that we have a actor.  If not, we direct the
  # user to install the facebook app.

  def ensure_actor
    if actor.nil?
      install_source = params[:install_source] || params[:s]
      forward_counter = params[:forward_counter].to_i
      
      breakout_to( new_facebook_session.install_url(
        :next => url_for( :canvas           => true, 
                          :fb               => false, 
                          :r                => params[:r],
                          :s                => install_source,
                          :forward_counter  => forward_counter ) ) )
      return false
    end
  end

  # This filter ensures that we have a actor and that user is a
  # super admin.  If not, the user is redirected to /game.

  def ensure_super_admin
    redirect_to "/game"  unless actor && actor.super_admin?
  end
  
  def ensure_moderator
    redirect_to "/game"  unless actor && actor.moderator?
  end    

  # Checks for the presence of our session cookie.  On the first request
  # within an iframe on a facebook page, facebook provides the user's
  # session_id.  This is used for authentication (set_actor), on
  # subsequent requests we need to confirm that our 3rd party cookie hasn't
  # been deleted due to browser security restrictions.
  #
  # This filter performs that check.
  #
  # It is paired with client-side javascript that checks for the presence
  # of our session cookie and then pings back with the session_id in a
  # url parameter.  This triggers sending the session cookie to the browser
  # a second time.  Usually the browser will accept the session cookie on
  # the second go around because it will now consider it a 1st party cookie.
  #
  # See also CookieController#confirm and some of the javascript includes in
  # the application layout and the functions check_cookie,
  # fix_cookie_with_ajax, and fix_cookie_with_form in public/javascripts/fb.js.

  def check_session_cookie
    logger.debug "*** check_session_cookie "

    if first_request_in_iframe?             # always reconfirm on first requests
      logger.debug "*** first request in iframe"
      
      session[:confirmed] = false
      return
    end

    logger.debug "*** session cookie is confirmed"  if session_cookie_confirmed?
    return  if session_cookie_confirmed?    # already confirmed the cookie

    if cookies[session_key]                 # cookie confirmed!
      logger.debug "*** there is a session_key in the cookie"

      session[:confirmed] = true
      return
    end
  end

  # Set our compact privacy policy for Internet Explorer.  This causes
  # IE to accept our 3rd party cookies without resorting to any redirects or
  # user interaction.

  def set_p3p_header
    response.headers["P3P"] = 'CP="CAO PSA OUR"'
  end

  def set_ie7_header
    response.headers["X-UA-Compatible"] = 'IE=7'
  end

  # Check to see if the user is logged out of facebook

  def check_facebook_logged_out
    logger.debug "*** Check facebook logged out"
    
    if params[:fb_sig_logged_out_facebook] == "1"
      render :template => "errors/logged_out", :layout => 'errors'
    end
  end

  # Attempt at dealing with IncorrectSignature exceptions. 

  def check_facebook_session
    begin
      set_facebook_session

    rescue Facebooker::Session::MissingOrInvalidParameter, StandardError => e
    # notify_hoptoad( e )
      reset_session
      clear_fb_cookies!

      install_source = params[:install_source] || params[:s]
      forward_counter = params[:forward_counter].to_i
          
      breakout_to( url_for( :canvas           => true,
                            :fb               => false, 
                            :r                => params[:r],
                            :s                => install_source,
                            :forward_counter  => forward_counter ) )
    end
  end







  ### Filters for general app stuff  
  
  def update_relationship
    if actor && params[:r] && params[:r] =~ /(\d+)/
      r = Relationship.accepted_invitation( actor.id, $1.to_i )
    end
  end
  
  # If the user has installed or removed the app since the last request
  # update the install / remove date.

  def update_install
    if actor && request_comes_from_facebook?
      if ! actor.installed? && facebook_params[:added]
        actor.install
      elsif actor.installed? && ! facebook_params[:added]
        actor.remove
      end
    end
  end

  # Check params for install_source and save to actor.  We only record
  # install_source if it hasn't been previously set and the user is relatively
  # new.

  def update_install_source
    s = params[:install_source] || params[:s]

    if  actor && s && ! actor.played?
      
      actor.update_attributes( 
        { :install_source => s, 
          :created_at => Time.now 
        } )

    end
  end

  def log_user_ids
    if actor
      logger.info "*** User: #{actor.id} (facebook_id: #{actor.facebook_id})"
    end
  end

  def action_name_safe
    # Eliminate any invalid iv characters from action.
    params[:action].gsub( /\W/, '' )
  end

  # Select a tab based on the name of the controller.  This sets an instance
  # variable "@#{controller_name}_tab" to "selected" (the class used by the
  # tabs partials.

  def select_tab
    instance_variable_set( "@#{controller_name}_tab", true )
    instance_variable_set( "@#{controller_name}_#{action_name_safe}_tab", true )
  end


  def invites_sent_msg
    unless params[:invites_sent].blank?
      flash.now[:success_msg] = "Your invitations have been sent!"
    end
  end

end
