module Facebooker
  class Api
    def initialize(session)
      @session = session
    end

    def method_missing(method_name, *args )

      ## Prepare to execute Facebook API call
      (api_class, api_method) = method_name.to_s.split('_', 2)      
      api_method = api_method.titleize.gsub(' ', '')
      api_method = api_method[0,1].downcase + api_method[1, api_method.length]
      
      params = args[0]
      params ||= {}
      # json encode any arrays within the params
      params.keys.each { |k| params[k] = params[k].to_json   if params[k].is_a?( Array ) }

      
      ## Execute call
      ret = @session.post( "facebook.#{api_class}.#{api_method}", params )


      ## Format the return value
      return ret  if ret.is_a?( Integer )
      
      if ret.is_a?( String ) && ret[0,1] == '{' and ret[-1,1] == '}'
        ret = JSON.parse( ret ).symbolize_keys
      end
      
      if ret.is_a?( Hash )
        recursive_symbolize_keys_and_prep_values!( ret )
      end
      
      if ret.is_a?( Array ) && ret.first.is_a?( Hash )
        ret.each { |item| recursive_symbolize_keys_and_prep_values!( item ) }
      end
      
      ret
    end
    
    private
      def recursive_symbolize_keys_and_prep_values! hash
        hash.symbolize_keys!
        hash[:uid] = hash[:uid].to_i  unless hash[:uid].nil?
        hash.values.select{ |v| v.is_a? Hash }.each{ |h| recursive_symbolize_keys!(h) }
      end
  end
end

class Hash    		
  def method_missing(method_id, *args, &block)
    method_name = method_id.to_s
    check = self.stringify_keys
    if check.keys.include?(method_name)
      check[method_name]
    else
      super
    end
  end
end
