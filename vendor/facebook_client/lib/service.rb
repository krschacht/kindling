# Lo-fi client for the Facebook API. E.g.:
#
#   fb = FacebookClient.new(:api_key => 'api-key', :secret => 'secret')
#   fb.call 'users.getInfo', :session_key => 'session-key', :uids => 'user-id', :fields => 'birthday'
#
# by Scott Raymond <sco@scottraymond.net>
# Public Domain.
#
module FacebookClient
  class ResponseError < StandardError; end
  class Service

    require 'net/http'
    require 'digest'
    def initialize(default_params={})
      @default_params = default_params.reverse_merge({
        :rest_server => 'http://api.facebook.com/restserver.php',
        :format      => 'JSON',
        :v           => '1.0',
        :api_key     => Base.api_key,
        :secret      => Base.secret
      })
    end

    def call(method, params={})
      params = @default_params.merge(params)
      params[:method]  ||= 'facebook.' + method
      params[:call_id] ||= Time.now.to_f.to_s
			params[:timeout] ||= 8 #seconds
      secret      = params.delete(:secret)
      rest_server = params.delete(:rest_server)
      timeout 		= params.delete(:timeout)

      raw_string = params.inject([]) { |args, pair| args << pair.join('=') }.sort.join
      params[:sig] = Digest::MD5.hexdigest(raw_string + secret)

			response = net_http_post(URI.parse(rest_server), params)
      response = ActiveSupport::JSON.decode(response.read_body)
      validate_response!(response)
      response
    end

		def net_http_post(uri, params)
			attempt = 0
			Net::HTTP.post_form(uri, params)
		rescue Errno::ECONNRESET, EOFError
			if attempt==0
				RAILS_DEFAULT_LOGGER.info "Net::HTTP post failure: #{uri}, #{params}"
				attempt+=1
				retry
			end
		end
    
		# Uncomment to use curl instead of net http

		# require 'curb'
		# def curl_post(uri, params, timeout)
		# 	attempt = 0
		# 	response = Curl::Easy.http_post(uri, *params) do |c|
		#         c.headers['content-type'] = 'application/x-www-form-urlencoded'
		# 		c.timeout = timeout # seconds
		#       end
		# 	return response
		# rescue Curl::Err::GotNothingError
		# 	if attempt == 0
		#         RAILS_DEFAULT_LOGGER.info 'Curl::Err::GotNothingError.. retrying'
		# 		attempt += 1
		#         retry
		#       end
		# end 

    def validate_response!(response)
      return unless response.is_a?(Hash) and response.has_key?('error_code')
      raise FacebookClient::ResponseError, "#{response['error_code']}: #{response['error_msg']}"
    end
  end
end