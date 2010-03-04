module FacebookClient
  
  module Controller
    
		def redirect_to_install_url
			# redirect the actor to Facebook's app install authorization url
			# after the app is authorized the actor is redirected to the current url
			strip_facebook_params = params.dup.delete_if { |k, v| !(k=~/(^fb_sig)|(format)|(_method)|(^_fb_from_hash)/).nil? }
			current_canvas_url = url_for( { 
					:controller => controller_name, 
					:action => action_name,
					:canvas => true }.update(strip_facebook_params) ) 
			install_url = "http://www.facebook.com/install.php?api_key=#{FacebookClient.api_key}&v=1.0&next=#{CGI.escape(current_canvas_url)}"
			redirect_to(install_url) and return false
	  end
    
    def redirect_to(*args)
			# use the fbml redirect tag on canvas page
			if params['fb_sig_in_iframe'].present?
			  redirect_top_to(*args)
      elsif params['fb_sig_in_canvas'].present? and params['fb_sig_in_profile_tab'].blank?
        render :text => fbml_redirect_tag(*args)
      else
        super
      end
    end
		
		def redirect_top_to(*args)
      @redirect_url = url_for(*args)
      render :layout => false, :inline => <<-HTML
        <html><head>
          <script type="text/javascript">  
            window.top.location.href = <%= @redirect_url.to_json -%>;
          </script>
          <noscript>
            <meta http-equiv="refresh" content="0;url=<%=h @redirect_url %>" />
            <meta http-equiv="window-target" content="_top" />
          </noscript>                
        </head></html>
      HTML
	  end
		
		def fbml_redirect_tag(url)
      "<fb:redirect url=\"#{url_for(url)}\" />"
    end
		
		def forward_to_next_param
			if !params[:next].blank?
				redirect_to(params[:next]) and return false
			end
		end
  end
  
end

module ::ActionController
  class AbstractRequest
    def request_method_with_facebook_client
      if parameters[:_method].blank?
        if %w{GET HEAD}.include?(parameters[:fb_sig_request_method])
          parameters[:_method] = parameters[:fb_sig_request_method]
        end
      end
      request_method_without_facebook_client
    end
    
    if new.methods.include?("request_method")
      alias_method_chain :request_method, :facebook_client 
    end
  end
end