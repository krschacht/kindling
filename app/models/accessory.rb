class Accessory < ActiveRecord::Base
  belongs_to :accessory_type
  belongs_to :garden
  belongs_to :sender
end
