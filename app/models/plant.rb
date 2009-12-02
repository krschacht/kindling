class Plant < ActiveRecord::Base
  belongs_to :plant_type
  belongs_to :garden
  belongs_to :sender
end
