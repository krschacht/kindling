class Visit < ActiveRecord::Base
  belongs_to :garden
  belongs_to :person
end
