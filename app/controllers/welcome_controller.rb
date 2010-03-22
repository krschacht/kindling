class WelcomeController < ApplicationController
  
  skip_before_filter  :ensure_installed
  
  def index
  end

end
