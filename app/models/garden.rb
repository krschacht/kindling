class Garden < ActiveRecord::Base
  belongs_to :person
  belongs_to :user
  belongs_to :scene

  has_many :plants
  has_many :accessories
end
