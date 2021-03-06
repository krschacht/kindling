require 'cgi'
require 'facebooker/api'

module Facebooker
  #
  # Raised when trying to perform an operation on a user
  # other than the logged in user (if that's unallowed)
  class NonSessionUser < StandardError;  end
  class Session

    #
    # Raised when a facebook session has expired.  This 
    # happens when the timeout is reached, or when the
    # user logs out of facebook
    # can be handled with:
    # rescue_from Facebooker::Session::SessionExpired, :with => :some_method_name
    class SessionExpired < StandardError; end

    class UnknownError < StandardError; end
    class ServiceUnavailable < StandardError; end
    class MaxRequestsDepleted < StandardError; end
    class HostNotAllowed < StandardError; end
    class MissingOrInvalidParameter < StandardError; end
    class InvalidAPIKey < StandardError; end
    class SessionExpired < StandardError; end
    class CallOutOfOrder < StandardError; end
    class IncorrectSignature     < StandardError; end
    class SignatureTooOld     < StandardError; end
    class TooManyUserCalls < StandardError; end
    class TooManyUserActionCalls < StandardError; end
    class InvalidFeedTitleLink < StandardError; end
    class InvalidFeedTitleLength < StandardError; end
    class InvalidFeedTitleName < StandardError; end
    class BlankFeedTitle < StandardError; end
    class FeedBodyLengthTooLong < StandardError; end
    class InvalidFeedPhotoSource < StandardError; end
    class InvalidFeedPhotoLink < StandardError; end    
    class TemplateDataMissingRequiredTokens < StandardError; end
    class FeedMarkupInvalid < StandardError; end
    class FeedTitleDataInvalid < StandardError; end
    class FeedTitleTemplateInvalid < StandardError; end
    class FeedBodyDataInvalid < StandardError; end
    class FeedBodyTemplateInvalid < StandardError; end
    class FeedPhotosNotRetrieved < StandardError; end
    class FeedTargetIdsInvalid < StandardError; end
    class TemplateBundleInvalid < StandardError; end
    class ConfigurationMissing < StandardError; end
    class FQLParseError < StandardError; end
    class FQLFieldDoesNotExist < StandardError; end
    class FQLTableDoesNotExist < StandardError; end
    class FQLStatementNotIndexable < StandardError; end
    class FQLFunctionDoesNotExist < StandardError; end
    class FQLWrongNumberArgumentsPassedToFunction < StandardError; end
    class PermissionError < StandardError; end
    class InvalidAlbumId < StandardError; end
    class AlbumIsFull < StandardError; end
    class MissingOrInvalidImageFile < StandardError; end
    class TooManyUnapprovedPhotosPending < StandardError; end
    class ExtendedPermissionRequired < StandardError; end
    class ReadMailboxExtendedPermissionRequired < StandardError; end
    class InvalidFriendList < StandardError; end
    class UserUnRegistrationFailed < StandardError
      attr_accessor :failed_users
    end
    class UserRegistrationFailed < StandardError
      attr_accessor :failed_users
    end

    API_SERVER_BASE_URL       = ENV["FACEBOOKER_API"] == "new" ? "api.new.facebook.com" : "api.facebook.com"
    API_PATH_REST             = "/restserver.php"
    WWW_SERVER_BASE_URL       = ENV["FACEBOOKER_API"] == "new" ? "www.new.facebook.com" : "www.facebook.com"
    WWW_PATH_LOGIN            = "/login.php"
    WWW_PATH_ADD              = "/add.php"
    WWW_PATH_INSTALL          = "/install.php"

    attr_writer :auth_token
    attr_reader :session_key
    attr_reader :secret_from_session

    def self.create(api_key=nil, secret_key=nil)
      api_key ||= self.api_key
      secret_key ||= self.secret_key
      raise ArgumentError unless !api_key.nil? && !secret_key.nil?
      new(api_key, secret_key)
    end

    def self.api_key
      extract_key_from_environment(:api) || extract_key_from_configuration_file(:api) rescue report_inability_to_find_key(:api)
    end

    def self.secret_key
      extract_key_from_environment(:secret) || extract_key_from_configuration_file(:secret) rescue report_inability_to_find_key(:secret)
    end

    def self.current
      Thread.current['facebook_session']
    end

    def self.current=(session)
      Thread.current['facebook_session'] = session
    end

    def login_url(options={})
      options = default_login_url_options.merge(options)
      "#{Facebooker.login_url_base}#{login_url_optional_parameters(options)}"
    end

    def install_url(options={})
      "#{Facebooker.install_url_base}#{install_url_optional_parameters(options)}"
    end

    # The url to get user to approve extended permissions
    # http://wiki.developers.facebook.com/index.php/Extended_permission
    #
    # permissions:
    # * email
    # * offline_access
    # * status_update
    # * photo_upload
    # * video_upload
    # * create_listing
    # * create_event
    # * rsvp_event
    # * sms
    # * read_mailbox
    def permission_url(permission,options={})
      options = default_login_url_options.merge(options)
      options = add_next_parameters(options)
      options << "&ext_perm=#{permission}"
      "#{Facebooker.permission_url_base}#{options.join}"
    end

    def connect_permission_url(permission,options={})
      options = default_login_url_options.merge(options)
      options = add_next_parameters(options)
      options << "&ext_perm=#{permission}"
      "#{Facebooker.connect_permission_url_base}#{options.join}"
    end

    def install_url_optional_parameters(options)
      optional_parameters = []      
      optional_parameters += add_next_parameters(options)
      optional_parameters.join
    end

    def add_next_parameters(options)
      opts = []
      opts << "&next=#{CGI.escape(options[:next])}" if options[:next]
      opts << "&next_cancel=#{CGI.escape(options[:next_cancel])}" if options[:next_cancel]
      opts
    end

    def login_url_optional_parameters(options)
      # It is important that unused options are omitted as stuff like &canvas=false will still display the canvas. 
      optional_parameters = []
      optional_parameters += add_next_parameters(options)
      optional_parameters << "&skipcookie=true" if options[:skip_cookie]
      optional_parameters << "&hide_checkbox=true" if options[:hide_checkbox]
      optional_parameters << "&canvas=true" if options[:canvas]
      optional_parameters << "&fbconnect=true" if options[:fbconnect]
      optional_parameters << "&return_session=true" if options[:return_session]
      optional_parameters << "&session_key_only=true" if options[:session_key_only]
      optional_parameters << "&req_perms=#{options[:req_perms]}" if options[:req_perms]
      optional_parameters.join
    end

    def default_login_url_options
      {}
    end

    def initialize(api_key, secret_key)
      @api_key        = api_key
      @secret_key     = secret_key
      @batch_request  = nil
      @session_key    = nil
      @uid            = nil
      @auth_token     = nil
      @secret_from_session = nil
      @expires        = nil
    end

    def secret_for_method(method_name)
      @secret_key
    end

    def auth_token
      @auth_token ||= post 'facebook.auth.createToken'
    end

    def infinite?
      @expires == 0
    end

    def expired?
      @expires.nil? || (!infinite? && Time.at(@expires) <= Time.now)
    end

    def secured?
      !@session_key.nil? && !expired?
    end

    def secure!(args = {})
      response = post 'facebook.auth.getSession', :auth_token => auth_token, :generate_session_secret => args[:generate_session_secret] ? "1" : "0"
      secure_with!(response['session_key'], response['uid'], response['expires'], response['secret'])
    end    
    
    def secure_with_session_secret!
      self.secure!(:generate_session_secret => true)
    end

    def secure_with!(session_key, uid = nil, expires = nil, secret_from_session = nil)
      @session_key = session_key
      @uid = uid ? Integer(uid) : post('facebook.users.getLoggedInUser', :session_key => session_key)
      @expires = expires ? Integer(expires) : 0
      @secret_from_session = secret_from_session
    end

    def fql_build_object(type, hash)
      case type
      when 'user'
        user = User.new
        user.session = self
        user.populate_from_hash!(hash)
        user
      # when 'photo'
      #   Photo.from_hash(hash)
      # when 'album'
      #   Album.from_hash(hash)
      # when 'page'
      #   Page.from_hash(hash)
      # when 'page_admin'
      #   Page.from_hash(hash)
      # when 'group'
      #   Group.from_hash(hash)
      # when 'event'
      #   Event.from_hash(hash)
      # when 'event_member'
      #   Event::Attendance.from_hash(hash)
      else
        hash
      end
    end

    def fql_query(query, format = 'XML')
      post('facebook.fql.query', :query => query, :format => format) do |response|
        type = response.shift
        if type.nil?
          []
        else
          response.shift.map do |hash|
            fql_build_object(type, hash)
          end
        end
      end
    end

    def fql_multiquery(queries, format = 'XML')
      results = {}
      post('facebook.fql.multiquery', :queries => queries.to_json, :format => format) do |responses|
        responses.each do |response|
          name = response.shift
          response = response.shift
          type = response.shift
          value = [] 
          unless type.nil?
            value = response.shift.map do |hash|
              fql_build_object(type, hash)
            end
          end
          results[name] = value
        end
      end
      results
    end

    def user
      @user ||= User.new(uid, self)
    end
    
    def users_standard(user_ids, fields=[])
      post("facebook.users.getStandardInfo",:uids=>user_ids.join(","),:fields=>User.standard_fields(fields)) do |users|
        users.map { |u| User.new(u)}
      end
    end

    def users(user_ids, fields=[])
      post("facebook.users.getInfo",:uids=>user_ids.join(","),:fields=>User.user_fields(fields)) do |users|
        users.map { |u| User.new(u)}
      end
    end

    def pages(options = {})
      raise ArgumentError, 'fields option is mandatory' unless options.has_key?(:fields)
      @pages ||= {}
      @pages[options] ||= post('facebook.pages.getInfo', options) do |response|
        response.map do |hash|
          Page.from_hash(hash)
        end
      end
    end

    def server_cache
      Facebooker::ServerCache.new(self)
    end

    def api
      Facebooker::Api.new(self)
    end

    ###
    # Retrieve a viewer's facebook stream
    # See http://wiki.developers.facebook.com/index.php/Stream.get for options
    #
    def get_stream(viewer_id, options = {})

      @stream = post('facebook.stream.get', prepare_get_stream_options(viewer_id, options), true) do |response|
        response
      end
    end

    # Only serialize the bare minimum to recreate the session.
    def marshal_load(variables)#:nodoc:
      fields_to_serialize.each_with_index{|field, index| instance_variable_set_value(field, variables[index])}
    end

    # Only serialize the bare minimum to recreate the session.    
    def marshal_dump#:nodoc:
      fields_to_serialize.map{|field| instance_variable_value(field)}
    end

    # Only serialize the bare minimum to recreate the session. 
    def to_yaml( opts = {} )
      YAML::quick_emit(self.object_id, opts) do |out|
        out.map(taguri) do |map|
          fields_to_serialize.each do |field|
            map.add(field, instance_variable_value(field))
          end
        end
      end
    end

    def instance_variable_set_value(field, value)
      self.instance_variable_set("@#{field}", value)
    end

    def instance_variable_value(field)
      self.instance_variable_get("@#{field}")
    end

    def fields_to_serialize
      %w(session_key uid expires secret_from_session auth_token api_key secret_key)
    end

    class Desktop < Session
      def login_url
        super + "&auth_token=#{auth_token}"
      end

      def secret_for_method(method_name)
        secret = auth_request_methods.include?(method_name) ? super : @secret_from_session
        secret
      end

      def post(method, params = {},use_session=false)
        if method == 'facebook.profile.getFBML' || method == 'facebook.profile.setFBML'
          raise NonSessionUser.new("User #{@uid} is not the logged in user.") unless @uid == params[:uid]
        end
        super
      end
      private
        def auth_request_methods
          ['facebook.auth.getSession', 'facebook.auth.createToken']
        end
    end

    def batch_request?
      @batch_request
    end

    def add_to_batch(req,&proc)
      batch_request = BatchRequest.new(req,proc)
      Thread.current[:facebooker_current_batch_queue]<<batch_request
      batch_request
    end

    # Submit the enclosed requests for this session inside a batch
    # 
    # All requests will be sent to Facebook at the end of the block
    # each method inside the block will return a proxy object
    # attempting to access the proxy before the end of the block will yield an exception
    #
    # For Example:
    #
    #   facebook_session.batch do
    #     @send_result = facebook_session.send_notification([12451752],"Woohoo")
    #     @albums = facebook_session.user.albums
    #   end
    #   puts @albums.first.inspect
    #
    # is valid, however
    #
    #   facebook_session.batch do
    #     @send_result = facebook_session.send_notification([12451752],"Woohoo")
    #     @albums = facebook_session.user.albums
    #     puts @albums.first.inspect
    #   end
    #
    # will raise Facebooker::BatchRequest::UnexecutedRequest
    #
    # If an exception is raised while processing the result, that exception will be
    # re-raised on the next access to that object or when exception_raised? is called
    #
    # for example, if the send_notification resulted in TooManyUserCalls being raised,
    # calling 
    #   @send_result.exception_raised? 
    # would re-raise that exception
    # if there was an error retrieving the albums, it would be re-raised when 
    #  @albums.first 
    # is called
    #
    def batch(serial_only=false)
      @batch_request=true
      Thread.current[:facebooker_current_batch_queue]=[]
      yield
      # Set the batch request to false so that post will execute the batch job
      @batch_request=false
      BatchRun.current_batch=Thread.current[:facebooker_current_batch_queue]
      post("facebook.batch.run",:method_feed=>BatchRun.current_batch.map{|q| q.uri}.to_json,:serial_only=>serial_only.to_s)
    ensure
      @batch_request=false
      BatchRun.current_batch=nil
    end

    def post_without_logging(method, params = {}, use_session_key = true, &proc)
      add_facebook_params(params, method)
      use_session_key && @session_key && params[:session_key] ||= @session_key
      final_params=params.merge(:sig => signature_for(params))
      if batch_request?
        add_to_batch(final_params,&proc)
      else
        result = service.post(final_params)
        result = yield result if block_given?
        result
      end
    end

    def post(method, params = {}, use_session_key = true, &proc)
      if batch_request? or Facebooker::Logging.skip_api_logging
        post_without_logging(method, params, use_session_key, &proc)
      else
        Logging.log_fb_api(method, params) do
          post_without_logging(method, params, use_session_key, &proc)
        end
      end
    end

    def post_file(method, params = {})
      base = params.delete(:base)
      Logging.log_fb_api(method, params) do
        add_facebook_params(params, method)
        @session_key && params[:session_key] ||= @session_key unless params[:uid]
        service.post_file(params.merge(:base => base, :sig => signature_for(params.reject{|key, value| key.nil?})))
      end
    end


    @configuration_file_path = nil

    def self.configuration_file_path
      @configuration_file_path || File.expand_path("~/.facebookerrc")
    end

    def self.configuration_file_path=(path)
      @configuration_file_path = path
    end

    private
      def add_facebook_params(hash, method)
        hash[:method] = method
        hash[:api_key] = @api_key
        hash[:call_id] = Time.now.to_f.to_s unless method == 'facebook.auth.getSession'
        hash[:v] = "1.0"
      end

      # This ultimately delgates to the adapter
      def self.extract_key_from_environment(key_name)
             Facebooker.send(key_name.to_s + "_key") rescue nil
      end

      def self.extract_key_from_configuration_file(key_name)
        read_configuration_file[key_name]
      end

      def self.report_inability_to_find_key(key_name)
        raise ConfigurationMissing, "Could not find configuration information for #{key_name}"
      end

      def self.read_configuration_file
        eval(File.read(configuration_file_path))
      end

      def service
        @service ||= Service.new(Facebooker.api_server_base, Facebooker.api_rest_path, @api_key)      
      end

      def uid
        @uid || (secure!; @uid)
      end

      def uid?
        !! @uid
      end

      def signature_for(params)
        params.delete_if { |k,v| v.nil? }
        raw_string = params.inject([]) do |collection, pair|
          collection << pair.map { |x|
            Array === x ? Facebooker.json_encode(x) : x
          }.join("=")
          collection
        end.sort.join
        Digest::MD5.hexdigest([raw_string, secret_for_method(params[:method])].join)
      end
      
      def ensure_array(value)
        value.is_a?(Array) ? value : [value]
      end

      def prepare_get_stream_options(viewer_id, options)
        opts = {}

        opts[:viewer_id] = viewer_id if viewer_id.is_a?(Integer)
        opts[:source_ids] = options[:source_ids] if options[:source_ids]
        opts[:start_time] = options[:start_time].to_i if options[:start_time]
        opts[:end_time] = options[:end_time].to_i if options[:end_time]
        opts[:limit] = options[:limit] if options[:limit].is_a?(Integer)
        opts[:metadata] = Facebooker.json_encode(options[:metadata]) if options[:metadata]
        opts
      end
  end

  class CanvasSession < Session
    def default_login_url_options
      {:canvas => true}
    end
  end
end
