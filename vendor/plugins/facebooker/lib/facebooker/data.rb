module Facebooker
  class Data
    def initialize(session)
      @session = session
    end

    ##
    # ** BETA ***
    # Gets a preference stored on Facebook
    # +pref_id+	The id of the preference to get
    def get_preference(pref_id)
      @session.post('facebook.data.getUserPreference', :pref_id=>pref_id)
    end

    ##
    # ** BETA ***
    # Sets a preference on Facebook
    # +pref_id+	The id of the preference to set
    # +value+ The value to set for this preference
    def set_preference(pref_id, value)
      @session.post('facebook.data.setUserPreference', :pref_id=>pref_id, :value=>value)
    end
  end
end
