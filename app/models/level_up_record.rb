class LevelUpRecord < ActiveRecord::Base
  belongs_to :person
  belongs_to :level
end
