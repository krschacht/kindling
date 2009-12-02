class AccessoryType < ActiveRecord::Base
  belongs_to :category
  has_many :accessories
end
