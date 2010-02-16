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

  def gambit_pay_panel( opts = { :width => 590, :height => 60, :campaign_key => Gambit.campaign_key } )
    campaign_key = opts[:campaign_key] || Gambit.campaign_key
    if current_user
      uid = current_user.id
      url = gambit_pay_url

      %Q( <iframe src="#{url}" 
                  frameborder="0"
                  scrolling="no" 
                  width="#{opts[:width]}" 
                  height="#{opts[:height]}" 
                  allowtransparency="true"></iframe> )
    end
  end
  
  def gambit_pay_url( campaign_key = Gambit.campaign_key, uid = current_user.id )
    "http://banners.getgambit.com/payment_banner?size=pbp&k=#{campaign_key}&uid=#{uid}"    
  end

  def gambit_offer_panel( opts = {} )
    opts[:width] ||= 604
    opts[:height] ||= 1750
    campaign_key = opts[:campaign_key] || Gambit.campaign_key
    uid = current_user.id
    url = ( opts[:url] || "http://getgambit.com/panel?" ) + "k=#{campaign_key}&uid=#{uid}"
    height = opts[:cover_height] ? "height: #{opts[:cover_height]}px; color: #FFFFFF;" : ""
    
    if current_user
      %Q( <div class="gambit_offer_panel">
          <div class="cover_top" style="width: #{opts[:width]}px; #{height}">
            <div #{'style="display: none;"' unless height == ""}>
              <p>After you complete an offer <span class="highlight">please write a review</span> to help other wizards.</p>

              <p>We hope that all of the offers are reputable, but <b>we are not affiliated with 
              these companies</b> so we can not guarantee. We partner with the company Gambit who provides them
              <b>Exercise your own best judgement in 
              evaluating an offer</b>. Also, if you do not receive credit, click "Offer Status" 
              below. If you do not see it there then click #{link_to "Gold Problems", "/donations/help"}
              and let us know so we can remedy!</p>
            </div>
          &nbsp;
          </div>
          <iframe src="#{url}" 
                  frameborder="0"
                  scrolling="no" 
                  width="#{opts[:width]}" 
                  height="#{opts[:height]}" 
                  allowtransparency="true"></iframe> 
          </div> )
    end
  end
  
end
