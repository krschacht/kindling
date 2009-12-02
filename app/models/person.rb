class Person < ActiveRecord::Base
  has_many :gardens
  has_many :plants, :through => :gardens
  has_many :accessories, :through => :gardens

  belongs_to :level
  has_many :level_up_records
  has_many :visits
end
