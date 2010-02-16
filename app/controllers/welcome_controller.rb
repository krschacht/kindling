class WelcomeController < ApplicationController
  
  skip_before_filter  :ensure_application_is_installed_by_facebook_user,
                      :ensure_authenticated_to_facebook,
                      :set_facebook_session
  
  def index
  end

end
