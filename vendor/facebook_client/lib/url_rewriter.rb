# Url Rewriting, stolen straight from Facebooker
#   this code rewrites routes for the facebook canvas:  
#   	url_for(:controller=>'users',:canvas=>true) => apps.facebook.com/canvasname/users
#     url_for(:controller=>'users',:canvas=>false) => my.callbackurl.com/users


module ::ActionController
  
  class AbstractRequest                         
    def relative_url_root
      FacebookClient.path_prefix 
    end                                         
  end
  
  class Base
    def self.relative_url_root
      FacebookClient.path_prefix
    end
  end
  
  class UrlRewriter
    RESERVED_OPTIONS << :canvas

    def link_to_canvas?(params, options)
      option_override = options[:canvas]
      return false if option_override == false # important to check for false. nil should use default behavior
      option_override || (can_safely_access_request_parameters? && (@request.parameters["fb_sig_in_canvas"] == "1" ||  @request.parameters[:fb_sig_in_canvas] == "1" ))
    end
    
    #rails blindly tries to merge things that may be nil into the parameters. Make sure this won't break
    def can_safely_access_request_parameters?
      @request.request_parameters
    end
  
    def rewrite_url_with_facebook_client(*args)
      options = args.first.is_a?(Hash) ? args.first : args.last
      is_link_to_canvas = link_to_canvas?(@request.request_parameters, options)
      if is_link_to_canvas && !options.has_key?(:host)
        options[:host] = "apps.facebook.com"
      end 
      options.delete(:canvas)
      FacebookClient.request_for_canvas(is_link_to_canvas) do
        rewrite_url_without_facebook_client(*args)
      end
    end
    
    alias_method_chain :rewrite_url, :facebook_client
  end
end

class ActionController::Routing::Route
  def recognition_conditions_with_facebook_client
    defaults = recognition_conditions_without_facebook_client 
    defaults << " env[:canvas] == conditions[:canvas] " if conditions[:canvas]
    defaults
  end
  alias_method_chain :recognition_conditions, :facebook_client
end

module FacebookClient
  module RouteSetExtensions
    def self.included(base)
      base.alias_method_chain :extract_request_environment, :facebook_client
    end

    def extract_request_environment_with_facebook_client(request)
      env = extract_request_environment_without_facebook_client(request)
      env.merge :canvas => (request.parameters[:fb_sig_in_canvas]=="1")
    end
  end
end
ActionController::Base::optimise_named_routes = false
ActionController::Routing::RouteSet.send :include, FacebookClient::RouteSetExtensions