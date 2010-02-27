module MiniAppHelper

  def full_name_linked( user, opt = {} )
    return "" if user.nil?
    fb_name(user.facebook_id)
  end

  # Depends on the lookup helper!

  def name( facebook_id, default="???" )
    @lookups ||= {}

    if @lookups[facebook_id] && @lookups[facebook_id][:name]
      @lookups[facebook_id][:name]
    else
      default
    end
  end

  def root_forum_tree( forum )

    case forum.area_is
    when :help
      link = link_to "Help Home", "/forums", { :target => "_top" }
    when :offers
      link = link_to "Back to Offers", "/donations/offers", { :target => "_top" }
    when :wiki
      link = link_to "Back to Wiki", "http://theenchantedisland.wikispaces.com/", { :target => "_top" }
    when :pub
      link = link_to "Back to Pub", "/pub/discussion", { :target => "_top" }
    end

    "#{link} &raquo;"
  end

end
