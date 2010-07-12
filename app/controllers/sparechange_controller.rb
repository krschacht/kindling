
# SparechangeController handles callbacks from Gambit.
#
# We skip all the application filters and use two filters specific to callback
# requests.

class SparechangeController < ApplicationController

  skip_before_filter  :ensure_installed, :except => :index

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

