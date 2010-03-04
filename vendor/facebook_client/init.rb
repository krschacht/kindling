# Include hook code here
require 'facebook_client'
require 'url_rewriter'
require 'service'
require 'controller'

module ::ActionController
  class Base
    def self.inherited_with_facebook_client(subclass)
      inherited_without_facebook_client(subclass)
      if subclass.to_s == "ApplicationController"
        subclass.send(:include,FacebookClient::Controller) 
      end
    end
    class << self
      alias_method_chain :inherited, :facebook_client
    end
  end
end

# asset host set to callback url
#ActionController::Base.asset_host = FacebookClient.params[:properties][:callback_url].to_s[0..-2] # remove trailing slash
