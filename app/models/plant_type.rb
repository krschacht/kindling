class PlantType < ActiveRecord::Base
  belongs_to :category
  has_many :plants
end
