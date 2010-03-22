require 'fileutils'

namespace :facebooker do

  desc "Create a basic facebooker.yml configuration file"
  task :setup => :environment do   
    facebook_config = File.join(RAILS_ROOT,"config","facebooker.yml")
    unless File.exist?(facebook_config)
      plugin_root = File.join(RAILS_ROOT,"vendor","plugins")
      facebook_config_tpl = File.join(plugin_root,"facebooker","generators","facebook","templates","config","facebooker.yml")
      FileUtils.cp facebook_config_tpl, facebook_config 
      puts "Ensure 'GatewayPorts yes' is enabled in the remote development server's sshd config when using any of the facebooker:tunnel:*' rake tasks"
      puts "Configuration created in #{RAILS_ROOT}/config/facebooker.yml"
    else
      puts "#{RAILS_ROOT}/config/facebooker.yml already exists"
    end
  end
  
  desc "Set environments facebook app properties from yaml"
  task :set_fb_app => :environment do                     
  	params = Facebooker.facebooker_config.symbolize_keys

  	required_params = [ :application_name, :canvas_name, :callback_url ]
  	required_params.each do |param_name|
  		raise "#{param_name} must be specified in config/facebooker.yml" unless params.has_key?(param_name)
  	end

  	ignore_params = [ :api_key, 
  	                  :secret_key, 
  	                  :pretty_errors, 
  	                  :set_asset_host_to_callback_url, 
  	                  :tunnel,
  	                  :xd_receiver,
  	                  :canvas_name ]
  	ignore_params.each { |p| params.delete( p ) }

  	puts "Registering FB App with properties: " 
  	puts YAML.dump( params )
  	Facebooker::Session.create.api.admin_set_app_properties( :properties => params )
  end  
end