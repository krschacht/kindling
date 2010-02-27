module FacebookClient

  class << self
    def params
      return @params  if @params
      
			@params = YAML.load_file( 
			  File.join(RAILS_ROOT, 'config', 'facebook_client.yml') )[RAILS_ENV].symbolize_keys
      @params[:properties].symbolize_keys!  if @params[:properties]
      @params
		end
    	
		def application_name
		  @application_name ||= params[:properties][:application_name]
		end
		
		def app_name
		  @application_name
		end
		
		def canvas
			@canvas ||= params[:canvas]
		end
		
		def api_key
			@api_key ||= params[:api_key]
		end
		
		def secret
			@secret ||= params[:secret]	
		end
		
		def api_id
			@api_id ||= params[:api_id]
		end

    def path_prefix
      @path_prefix
    end

    def facebook_path_prefix
      "/#{canvas}"
    end
    
    def request_for_canvas(is_canvas_request)
      original_path_prefix = @path_prefix 
      begin
        @path_prefix = facebook_path_prefix if is_canvas_request
        yield
      ensure
        @path_prefix = original_path_prefix
      end
    end
  end
end