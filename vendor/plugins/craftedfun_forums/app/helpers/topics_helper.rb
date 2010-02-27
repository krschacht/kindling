module TopicsHelper      

  def flagged_color_waiting_on_moderator?( topic )
    topic.flagged? and
    ! topic.posts.any? { |p| p.author.admin? } and
    current_user.moderator?
  end
  
  def flagged_hide_waiting_on_users?( topic )
    topic.flagged? and
    topic.last_post_author.super_admin? and
    current_user.super_admin? and
    ! @forum 
  end
  
  def posts_page_link( page )
    %Q( <a  href="javascript:;" 
            onclick="posts_paginate.goto_page( #{page} );"
            class="posts_page#{ page }">#{ page+1 }</a> )
  end
  
  def topic_lock_control( topic )
    return ""  if topic.nil?

    if topic.locked?
      js_button( "Unlock Topic",
        :js     => "unlock_topic( #{topic.id} );",
        :class  => "unlock_button" )
    else
      js_button( "Lock Topic",
        :js     => "lock_topic( #{topic.id} );",
        :class  => "lock_button" )
    end
  end
  
  def topic_sticky_control( topic )
    return ""  if topic.nil?

    if topic.sticky?
      js_button( "Unstick Topic",
        :js     => "unstick_topic( #{topic.id} );",
        :class  => "unstick_button" )
    else
      js_button( "Stick Topic",
        :js     => "stick_topic( #{topic.id} );",
        :class  => "stick_button" )
    end
  end

  def topic_flag_control( topic )
    return ""  if topic.nil?

    if topic.flagged?
      if current_user.moderator?
        js_button( "Unflag Topic",
          :js     => "unflag_topic( #{topic.id} );",
          :class  => "unflag_button" )
      end
    else
      js_button( "Flag Topic for Admins",
        :js     => "flag_topic( #{topic.id} );",
        :enable => topic.flaggable? || current_user.moderator?,
        :class  => "flag_button" )
    end
  end

end
