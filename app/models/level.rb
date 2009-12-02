class Level < ActiveRecord::Base
  has_many :people
  has_many :level_up_records
end
