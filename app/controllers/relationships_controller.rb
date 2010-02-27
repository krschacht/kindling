
class RelationshipsController < ApplicationController

  layout nil
  
  def invite
    @exclude_ids = actor.friends.collect { |f| f.uid }.join( "," )
  end
  
  def invites_sent
    if params[:ids] && actor
      begin
        InviteSent.create( :user        => actor,
                           :number_sent => params[:ids].length )
      rescue => e
        logger.error "Error: invites_sent for #{actor.inspect}: #{e}"
      end
    end
    
    redirect_to root_url(:only_path => false, :canvas => true, :invites_sent => params[:ids] )
  end

end

