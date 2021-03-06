require 'facebooker/model'
module Facebooker
  #
  # Holds attributes and behavior for a Facebook User
  class User
    include Model

    class Status
      include Model
      attr_accessor :message, :time, :status_id
    end
    FIELDS = [:status, :political, :pic_small, :name, :quotes, :is_app_user, :tv, :profile_update_time, :meeting_sex, :hs_info, :timezone, :relationship_status, :hometown_location, :about_me, :wall_count, :significant_other_id, :pic_big, :music, :work_history, :sex, :religion, :notes_count, :activities, :pic_square, :movies, :has_added_app, :education_history, :birthday, :birthday_date, :first_name, :meeting_for, :last_name, :interests, :current_location, :pic, :books, :affiliations, :locale, :profile_url, :proxied_email, :email_hashes, :allowed_restrictions, :pic_with_logo, :pic_big_with_logo, :pic_small_with_logo, :pic_square_with_logo, :online_presence, :verified, :profile_blurb, :username, :website, :is_blocked, :family, :email]
    STANDARD_FIELDS = [:uid, :first_name, :last_name, :name, :timezone, :birthday, :sex, :affiliations, :locale, :profile_url, :proxied_email, :email]
    populating_attr_accessor(*FIELDS)

    populating_attr_reader :status

    attr_accessor :request_locale

    # Can pass in these two forms:
    # id, session, (optional) attribute_hash
    # attribute_hash
    def initialize(*args)
      @friends            = nil
      @current_location   = nil
      @pic                = nil
      @hometown_location  = nil
      @populated          = false
      @session            = nil
      @id                 = nil
      if (args.first.kind_of?(String) || args.first.kind_of?(Integer)) && args.size==1
        self.uid = args.shift
        @session = Session.current
      elsif (args.first.kind_of?(String) || args.first.kind_of?(Integer)) && args[1].kind_of?(Session)
        self.uid = args.shift
        @session = args.shift
      end
      if args.last.kind_of?(Hash)
        populate_from_hash!(args.pop)
      end
    end

    id_is :uid
    alias :facebook_id :id

    def events(params={})
     #  @events ||= {}
     # [:start_time,:end_time].compact.each do |key|
     #   params[key] = params[key].to_i
     # end
     #  puts @events[params.to_s].nil?
     # @events[params.to_s] ||= @session.post('facebook.events.get', {:uid => self.id}.merge(params)).map do |event|
     #   Event.from_hash(event)
     # end
    end

    def rsvp_event(eid, rsvp_status, options = {})
      # result = @session.post('facebook.events.rsvp', options.merge(:eid => eid, :rsvp_status => rsvp_status))
      # result == '1' ? true : false
    end

    def friends=(list_of_friends,flid=nil)
      @friends_hash ||= {}
      #  flid=cast_to_friend_list_id(flid)
      #  #use __blank instead of nil so that this is cached
      cache_key = flid||"__blank"
      # 
      @friends_hash[cache_key] ||= list_of_friends
    end

    def friends(flid = nil)
      @friends_hash ||= {}
      #  flid=cast_to_friend_list_id(flid)
      # 
      #  #use __blank instead of nil so that this is cached
      cache_key = flid||"__blank"
      #  options = {:uid=>self.id}
      #  options[:flid] = flid unless flid.nil?
      #  @friends_hash[cache_key] ||= @session.post('facebook.friends.get', options,false).map do |uid|
      #     User.new(uid, @session)
      # end
      @friends_hash[cache_key] ||= @session.api.friends_get( :uid => self.id )
      # @friends_hash[cache_key]
    end

    def friend_ids
      # options = {:uid => self.id}
      # @session.post('facebook.friends.get', options, false)
    end

    ###
    # Publish a post into the stream on the user's Wall and News Feed.  This
    # post also appears in the user's friend's streams.  The +publish_stream+
    # extended permission must be granted in order to use this method.
    #
    # See: http://wiki.developers.facebook.com/index.php/Stream.publish
    #
    # +target+ can be the current user or some other user.
    #
    # To publish to a Page on the Page's behave, specify the page id as
    # :uid and set :post_as_page to 'true', use the current user as target
    #
    # Example:
    #   # Publish a message to my own wall:
    #   me.publish_to(me, :message => 'hello world')
    #
    #   # Publish to a friend's wall with an action link:
    #   me.publish_to(my_friend,  :message => 'how are you?', :action_links => [
    #     :text => 'my website',
    #     :href => 'http://tenderlovemaking.com/'
    #   ])
    def publish_to(target, options = {})
      @session.post('facebook.stream.publish', prepare_publish_to_options(target, options), false)
    end

    # Prepares options for the stream.publish
    def prepare_publish_to_options(target, options)
      opts = {:uid          => self.id,
              :target_id    => target.id,
              :message      => options[:message]}

      if a = options[:attachment]
        opts[:attachment] = convert_attachment_to_json(a)
      end
      if (links = options[:action_links] && Facebooker.json_encode(options[:action_links]))
        opts[:action_links] = links
      end
      unless options[:uid].nil?
        opts[:uid] = options[:uid]
      end
      if options[:post_as_page]
        opts.delete(:target_id)
      end
      opts
    end
    
    def convert_attachment_to_json(attachment)
      a = attachment.respond_to?(:to_hash) ? attachment.to_hash : attachment
      Facebooker.json_encode(a)
    end

    def friends!(*fields)
      @friends ||= session.post('facebook.users.getInfo', :fields => collect(fields), :uids => friends.map{|f| f.id}.join(',')).map do |hash|
        User.new(hash['uid'], session, hash)
      end
    end

    ###
    # Retrieve profile data for logged in user
    # Optional: list of fields to retrieve as symbols
    def populate(*fields)
      arguments = {:fields => collect(fields), :uids => id}
      arguments[:locale]=request_locale unless request_locale.nil?
      session.post('facebook.users.getInfo', arguments) do |response|
        populate_from_hash!(response.first)
      end
    end

    def friends_with?(user_or_id)
      friends.map{|f| f.to_i}.include?(user_or_id.to_i)
    end

    def friends_with_this_app
      @friends_with_this_app ||= friend_ids_with_this_app.map do |uid|
        User.new(uid, session)
      end
    end

    def friend_ids_with_this_app
      @friend_ids_with_this_app ||= session.post('facebook.friends.getAppUsers')
    end

    def groups(gids = [])
      # args = gids.empty? ? {} : {:gids => gids}
      # @groups ||= session.post('facebook.groups.get', args).map do |hash|
      #   group = Group.from_hash(hash)
      #   group.session = session
      #   group
      # end
    end

    def notifications
      @notifications ||= {} # Notifications.from_hash(session.post('facebook.notifications.get'))
    end

    def profile_fbml
      session.post('facebook.profile.getFBML', :uid => id)
    end

    def profile_fbml=(markup)
      set_profile_fbml(markup, nil, nil, nil)
    end

    def mobile_fbml=(markup)
      set_profile_fbml(nil, markup, nil,nil)
    end

    def profile_action=(markup)
      set_profile_fbml(nil, nil, markup,nil)
    end

    def profile_main=(markup)
     set_profile_fbml(nil,nil,nil,markup)
    end

    def set_profile_fbml(profile_fbml, mobile_fbml, profile_action_fbml, profile_main = nil)
      parameters = {:uid => id}
      parameters[:profile] = profile_fbml if profile_fbml
      parameters[:profile_action] = profile_action_fbml if profile_action_fbml
      parameters[:mobile_profile] = mobile_fbml if mobile_fbml
      parameters[:profile_main] = profile_main if profile_main
      session.post('facebook.profile.setFBML', parameters,false)
    end

    def set_profile_info(title, info_fields, format = :text)
      session.post('facebook.profile.setInfo', :title => title, :uid => id,
        :type => format.to_s == "text" ? 1 : 5, :info_fields => info_fields.to_json)
    end

    def get_profile_info
      session.post('facebook.profile.getInfo', :uid => id)
    end

    ##
    # This DOES NOT set the status of a user on Facebook
    # Use the set_status method instead
    def status=(message)
      case message
      when String,Status
        @status = message
      when Hash
        @status = Status.from_hash(message)
      end
    end

    def statuses( limit = 50 )
      session.post('facebook.status.get', {:uid => uid, :limit => limit}).collect { |ret| Status.from_hash(ret) }
    end

    ##
    # Set the status for a user
    # DOES NOT prepend "is" to the message
    #
    # requires extended permission.
    def set_status(message)
      self.status=message
      session.post('facebook.users.setStatus',{:status=>message,:status_includes_verb=>1,:uid => uid}, false) do |ret|
        ret
      end
    end

    def has_permission?(ext_perm) # ext_perm = email, offline_access, status_update, photo_upload, create_listing, create_event, rsvp_event, sms
      session.post('facebook.users.hasAppPermission', {:ext_perm=>ext_perm, :uid => uid}, false) == "1"
    end

    def app_user?
      session.post('facebook.users.isAppUser', {:uid => self.id}, use_session_key = true)
    end

    def has_permissions?(ext_perms)
      ext_perms.all?{|p| has_permission?(p)}
    end

    def set_cookie(name, value, expires=nil, path=nil)
      session.post('facebook.data.setCookie',
        :uid => self.id,
        :name => name,
        :value => value,
        :expires => expires,
        :path => path) { |response| response == '1' }
    end

    def get_cookies(name=nil)
      session.post('facebook.data.getCookies', :uid => self.id, :name => name)
    end

    def get_preference(pref_id)
      session.post('facebook.data.getUserPreference', :pref_id=>pref_id)
    end

    def set_preference(pref_id, value)
      session.post('facebook.data.setUserPreference', :pref_id=>pref_id, :value=>value)
    end

    ##
    # Returns the user's id as an integer
    def to_i
      id
    end

    def to_s
      id.to_s
    end
    
    
    ### NEW DASHBOARD API STUFF
    
    def dashboard_count
      session.post('facebook.dashboard.getCount', :uid => uid)
    end
    
    def dashboard_count=(new_count)
      session.post('facebook.dashboard.setCount', :uid => uid, :count => new_count)
    end
    
    def dashboard_increment_count
      session.post('facebook.dashboard.incrementCount', :uid => uid)
    end
    
    def dashboard_decrement_count
      session.post('facebook.dashboard.decrementCount', :uid => uid)
    end
    
    # The following methods are not bound to a specific user but do relate to Users in general,
    #   so I've made them into class methods.
    
    # Facebooker::User.dashboard_multi_get_count ['1234', '5678']
    def self.dashboard_multi_get_count(*uids)
     Facebooker::Session.create.post("facebook.dashboard.multiGetCount", :uids => uids.flatten)
    end
    
    # Facebooker::User.dashboard_multi_set_count({ '1234' => '11', '5678' => '22' })
    def self.dashboard_multi_set_count(ids)
      Facebooker::Session.create.post("facebook.dashboard.multiSetCount", :ids => ids.to_json)
    end
    
    # Facebooker::User.dashboard_multi_increment_count ['1234', '5678']
    def self.dashboard_multi_increment_count(*uids)
      Facebooker::Session.create.post("facebook.dashboard.multiIncrementCount", :uids => uids.flatten.collect{ |uid| uid.to_s }.to_json)
    end
    
    # Facebooker::User.dashboard_multi_decrement_count ['1234', '5678']
    def self.dashboard_multi_decrement_count(*uids)
      Facebooker::Session.create.post("facebook.dashboard.multiDecrementCount", :uids => uids.flatten.collect{ |uid| uid.to_s }.to_json)
    end
    
    
    
    
    def get_news(*news_ids)
      params = { :uid => uid }
      params[:news_ids] = news_ids.flatten if news_ids
      
      session.post('facebook.dashboard.getNews', params)
    end
    
    # facebook_session.user.add_news [{ :message => 'Hey, who are you?', :action_link => { :text => "I-I'm a test user", :href => 'http://facebook.er/' }}], 'http://facebook.er/icon.png'
    def add_news(news, image=nil)
      params = { :uid => uid }
      params[:news] = news
      params[:image] = image if image
      
      session.post('facebook.dashboard.addNews', params)
    end
    
    # facebook_session.user.clear_news ['111111']
    def clear_news(*news_ids)
      params = { :uid => uid }
      params[:news_ids] = news_ids.flatten if news_ids
      
      session.post('facebook.dashboard.clearNews', params)
    end
    
    # Facebooker::User.multi_add_news(['1234', '4321'], [{ :message => 'Hi users', :action_link => { :text => "Uh hey there app", :href => 'http://facebook.er/' }}], 'http://facebook.er/icon.png')
    def self.multi_add_news(uids, news, image=nil)
      params = { :uids => uids, :news => news }
      params[:image] = image if image

      Facebooker::Session.create.post("facebook.dashboard.multiAddNews", params)
    end
    
    # Facebooker::User.multi_clear_news({"1234"=>["319103117527"], "4321"=>["313954287803"]})
    def self.multi_clear_news(ids)
      Facebooker::Session.create.post("facebook.dashboard.multiClearNews", :ids => ids.to_json)
    end
    
    # Facebooker::User.multi_get_news({"1234"=>["319103117527"], "4321"=>["313954287803"]})
    def self.multi_get_news(ids)
      Facebooker::Session.create.post('facebook.dashboard.multiGetNews', :ids => ids.to_json)
    end
    
    # facebook_session.user.get_activity '123'
    def get_activity(*activity_ids)
      params = {}
      params[:activity_ids] = activity_ids.flatten if activity_ids
      
      session.post('facebook.dashboard.getActivity', params)
    end
    
    # facebook_session.user.publish_activity({ :message => '{*actor*} rolled around', :action_link => { :text => 'Roll around too', :href => 'http://facebook.er/' }})
    def publish_activity(activity)
      session.post('facebook.dashboard.publishActivity', { :activity => activity.to_json })
    end
    
    # facebook_session.user.remove_activity ['123']
    def remove_activity(*activity_ids)
      session.post('facebook.dashboard.removeActivity', { :activity_ids => activity_ids.flatten })
    end
    
    
    ##
    # Two Facebooker::User objects should be considered equal if their Facebook ids are equal
    def ==(other_user)
      other_user.is_a?(User) && id == other_user.id
    end


    # register a user with Facebook
    # users should be a hast with at least an :email field
    # you can optionally provide an :account_id field as well

    def self.register(users)
      user_map={}
      users=users.map do |h|
        returning h.dup do |d|
          if email=d.delete(:email)
            hash = hash_email(email)
            user_map[hash]=h
            d[:email_hash]=hash
          end
        end
      end
      Facebooker::Session.create.post("facebook.connect.registerUsers",:accounts=>users.to_json) do |ret|
        ret.each do |hash|
          user_map.delete(hash)
        end
        unless user_map.empty?
          e=Facebooker::Session::UserRegistrationFailed.new
          e.failed_users = user_map.values
          raise e
        end
        ret
      end
    end

    # Get a count of unconnected friends
    def getUnconnectedFriendsCount
      session.post("facebook.connect.getUnconnectedFriendsCount")
    end


    # Unregister an array of email hashes
    def self.unregister(email_hashes)
      Facebooker::Session.create.post("facebook.connect.unregisterUsers",:email_hashes=>email_hashes.to_json) do |ret|
        ret.each do |hash|
          email_hashes.delete(hash)
        end
        unless email_hashes.empty?
          e=Facebooker::Session::UserUnRegistrationFailed.new
          e.failed_users = email_hashes
          raise e
        end
        ret
      end
    end

    # unregister an array of email addresses
    def self.unregister_emails(emails)
      emails_hash  = {}
      emails.each {|e| emails_hash[hash_email(e)] = e}
      begin
        unregister(emails_hash.keys).collect {|r| emails_hash[r]}
      rescue
        # re-raise with emails instead of hashes.
        e = Facebooker::Session::UserUnRegistrationFailed.new
        e.failed_users = $!.failed_users.collect { |f| emails_hash[f] }
        raise e
      end
    end

    def self.hash_email(email)
      email = email.downcase.strip
      crc=Zlib.crc32(email)
      md5=Digest::MD5.hexdigest(email)
      "#{crc}_#{md5}"
    end

    def self.cast_to_facebook_id(object)
      if object.respond_to?(:facebook_id)
        object.facebook_id
      else
        object
      end
    end

    def self.user_fields(fields = [])
      valid_fields(fields)
    end

    def self.standard_fields(fields = [])
      valid_fields(fields,STANDARD_FIELDS)
    end

    private

    def self.valid_fields(fields, allowable=FIELDS)
      allowable.reject{|field_name| !fields.empty? && !fields.include?(field_name)}.join(',')
    end

    def collect(fields, allowable=FIELDS)
      allowable.reject{|field_name| !fields.empty? && !fields.include?(field_name)}.join(',')
    end

    def profile_pic_album_id
      merge_aid(-3, id)
    end

    def merge_aid(aid, uid)
      (uid << 32) + (aid & 0xFFFFFFFF)
    end

  end
end
