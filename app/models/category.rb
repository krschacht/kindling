class Category < ActiveRecord::Base
  has_many :plants
  has_many :accessories
end
