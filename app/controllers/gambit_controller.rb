
# GambitController handles callbacks from Gambit.
#
# We skip all the application filters and use two filters specific to callback
# requests.

class GambitController < ApplicationController

  skip_filter  :ensure_application_is_installed_by_facebook_user,
               :ensure_authenticated_to_facebook,
               :set_facebook_session,
               :set_current_user,
               :log_user_ids,
               :set_ie7_header,
               :update_install,
               :update_install_source,
               :select_tab
          :except => :index

  before_filter :check_gambit_whitelist, :only => ['postback']

  def index
  end
  
  def postback
    begin
      GambitTransaction.record( params )

      render :text => "OK"
    rescue => e
      notify_hoptoad( e )
      render :text => "ERROR:RESEND"
    end
  end

  private

  IP_WHITELIST = /72\.52\.114\.\d+/

  def check_gambit_whitelist
    if RAILS_ENV == "production" && request.remote_ip !~ IP_WHITELIST
      render :text => "404", :status => 404
    end
  end

end

