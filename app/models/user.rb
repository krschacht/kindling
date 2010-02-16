class User < ActiveRecord::Base

  validates_presence_of :facebook_id, :currency, :premium_currency, :points

  validates_numericality_of :currency, :greater_than_or_equal_to => 0
  validates_numericality_of :premium_currency, :greater_than_or_equal_to => 0

  validates_uniqueness_of :facebook_id

  def installed?
    installed_at && ! removed_at
  end

  def install
    self.installed_at = Time.now
    self.removed_at = nil
    save
  end

  def remove
    self.removed_at = Time.now
    self.session_id = nil       # The facebook session will no longer be valid
    save
  end

  def super_admin?
    admin_level >= 100
  end

  def moderator?
    admin_level >= 10
  end

  def banned?
    admin_level == -1
  end

  def played?
    total_plays > 0
  end
    
end
