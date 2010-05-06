class JobsController < ApplicationController

  def index
  end

  def perform
    actor.played!
    actor.adjust_energy!( -3 )
  end

end
