class PlayController < ApplicationController
  def index
  end

  def foo
         @current_facebook_user = facebook_session.user
  end

end
