class Visit < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :plays, :date, :user

end
