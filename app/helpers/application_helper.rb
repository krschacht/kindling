# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_fb_session_data
    facebooker_session = @facebook_session.clone
    facebooker_session.instance_variable_set("@secret_key",'xxxxxxxxxxxxxxxxxxx')
    facebooker_session.to_yaml
  end
  
  def find_session_by_id( sid )
    defined?( SESSION_CACHE ) ? SESSION_CACHE.get( sid ) || {} : {}
  end
  
  def session_id
    request.session_options[:id]
  end
  
  def tab( text, opts={}, html_opts={} )
    href     = opts.delete(:href)
    classes  = ""
    classes += " first"   if opts.delete(:first)
    classes += " last"    if opts.delete(:last)

    html_opts[:class] ||= ""
    html_opts[:class] += " selected"  if opts.delete(:selected)

    # Set these as defaults to save typing :)
    opts[:host]         = 'apps.facebook.com'
    opts[:only_path]    = false
    opts[:canvas]       = true
    html_opts[:target]  = '_top'

    if href
      %Q(<li class="#{classes}">#{link_to text, href, opts, html_opts}</li>)
    else
      %Q(<li class="#{classes}">#{link_to text, opts, html_opts}</li>)
    end
  end
  
end
