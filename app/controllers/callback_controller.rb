# CallbackController handles callbacks from Facebook.  These are not user
# generated interactions, rather they're notifications that users have,
# for example, uninstalled our app.
#
# We skip all the application filters and use two filters specific to callback
# requests.

class CallbackController < ApplicationController

  skip_filter   :setup_browser_view, :ensure_installed
  before_filter :verify_request_from_facebook, :set_user

  # Delegate to User#install if the user has installed the app.

  def install
    @user.install  if @user && facebook_params[:added]

    render :nothing => true
  end

  # Delegate to User#remove if the user has removed the app.

  def remove
    @user.remove  if @user && facebook_params[:uninstall]

    render :nothing => true
  end

  protected

  # Authenticate that callback requests have actually come from Facebook.

  def verify_request_from_facebook
    unless request_comes_from_facebook?
      render :nothing => true
      return
    end
  end

  # Sets the @user instance variable to the user we're being notified about.
  # We can't use the application filter set_current_user because we're not
  # given a facebook session for some callbacks.

  def set_user
    if facebook_params['user']
      @user = User.for( facebook_params['user'] )
    end
  end

end

