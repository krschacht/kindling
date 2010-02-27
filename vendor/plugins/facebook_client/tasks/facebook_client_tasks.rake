desc "Set environments facebook app properties from yaml"
task :set_fb_app => :environment do                     
	
	# load and validate params
	params = FacebookClient.params[:properties].symbolize_keys 
	required_params = [ :application_name, :callback_url ]
	required_params.each do |param_name|
		raise "#{param_name} must be given" unless params.has_key?(param_name)
	end
	
	# set default params
	params[:uninstall_url] ||= params[:callback_url]
	default_params = {
		:use_iframe => 0,
		:desktop => 0,
		:is_mobile => 0,
		:private_install => 0,
		:installable => 1,
		:dev_mode => 0,
		:wide_mode => 1,
		:email => 'facebook_user_support@davcro.com'
	}
	properties = default_params.update(params)
	
	puts "Registering FB App with properties: " 
	puts YAML.dump(properties)
	@service = FacebookClient::Service.new
	@service.call('admin.setAppProperties', :properties => properties.to_json)
end
