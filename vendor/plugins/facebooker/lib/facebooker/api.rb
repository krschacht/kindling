module Facebooker
  class Api
    def initialize(session)
      @session = session
    end

    def method_missing(method_name, *args )
      (api_class, api_method) = method_name.to_s.split('_', 2)      
      api_method = api_method.titleize.gsub(' ', '')
      api_method = api_method[0,1].downcase + api_method[1, api_method.length]
      
      hash = args[0]
      hash ||= {}
      hash.keys.each { |k| hash[k] = hash[k].to_json   if hash[k].is_a?( Array ) }
      
      ret = @session.post( "facebook.#{api_class}.#{api_method}", hash )

      ## Format return value
      return ret  if ret.is_a?( Integer )
      
      if ret.is_a?( String ) && ret[0,1] == '{' and ret[-1,1] == '}'
        ret = JSON.parse( ret ).symbolize_keys
      end
      
      if ret.is_a?( Hash )
        recursive_symbolize_keys!( ret )
      end
      
      if ret.is_a?( Array ) && ret.first.is_a?( Hash )
        ret.each { |item| recursive_symbolize_keys!( item ) }
      end
      
      ret
    end
    
    private
      def recursive_symbolize_keys! hash
        hash.symbolize_keys!
        hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
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
