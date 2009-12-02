# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  ensure_authenticated_to_facebook
  ensure_application_is_installed_by_facebook_user

  before_filter :set_facebook_session
  helper_method :facebook_session, :api_key, :xd_receiver

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def api_key
    Facebooker.facebooker_config['api_key']
  end

  def xd_receiver
    "/xd_receiver.htm"
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
