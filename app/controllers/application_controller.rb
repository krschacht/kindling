# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all

  helper_method :facebook_session, 
                :api_key, 
                :xd_receiver,
                :current_user,
                :action_name_safe

  attr_reader   :current_user

  ensure_authenticated_to_facebook
  ensure_application_is_installed_by_facebook_user

  before_filter :set_facebook_session,
                :set_current_user,
                :log_user_ids,
                :set_ie7_header,
                :update_install,
                :update_install_source,
                :select_tab

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def api_key
    Facebooker.facebooker_config['api_key']
  end

  def xd_receiver
    "/xd_receiver.htm"
  end

  def set_current_user
    if facebook_session
      @current_user = User.find_or_create_by_facebook_id(facebook_session.user.id)
    end
  end

  def log_user_ids
    if current_user
      logger.info "*** User: #{current_user.id} (facebook_id: #{current_user.facebook_id})"
    end
  end
  
  def set_ie7_header
    response.headers["X-UA-Compatible"] = 'IE=7'
  end
  
  # If the user has installed or removed the app since the last request
  # update the install / remove date.

  def update_install
    if current_user && request_comes_from_facebook?
      if ! current_user.installed? && facebook_params[:added]
        current_user.install
      elsif current_user.installed? && ! facebook_params[:added]
        current_user.remove
      end
    end
  end

  # Check params for install_source and save to current_user.  We only record
  # install_source if it hasn't been previously set and the user is relatively
  # new.

  def update_install_source
    s = params[:install_source] || params[:s]

    if  current_user && s && ! current_user.played?
      
      current_user.update_attributes( 
        { :install_source => s, 
          :created_at => Time.now 
        } )

    end
  end

  def action_name_safe
    # Eliminate any invalid iv characters from action.
    params[:action].gsub( /\W/, '' )
  end

  def select_tab
    instance_variable_set( "@#{controller_name}_tab", true )
    instance_variable_set( "@#{controller_name}_#{action_name_safe}_tab", true )
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
