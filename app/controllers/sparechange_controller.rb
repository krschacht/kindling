
# SparechangeController handles callbacks from Gambit.
#
# We skip all the application filters and use two filters specific to callback
# requests.

class SparechangeController < ApplicationController

  skip_filter  :ensure_application_is_installed_by_facebook_user,
               :ensure_authenticated_to_facebook,
               :set_facebook_session,
               :set_current_user,
               :log_user_ids,
               :set_ie7_header,
               :update_install,
               :update_install_source,
               :select_tab,
          :except => :index

  def postback
    begin
      SparechangeTransaction.record( params )

      render :text => "OK"
    rescue => e
      notify_hoptoad( e )
      render :text => "ERROR:RESEND"
    end
  end

end

