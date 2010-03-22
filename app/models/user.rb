class User < ActiveRecord::Base
  
  validates_presence_of :facebook_id, :currency, :premium_currency

  validates_numericality_of :currency, :greater_than_or_equal_to => 0
  validates_numericality_of :premium_currency, :greater_than_or_equal_to => 0

  validates_uniqueness_of :facebook_id

  has_many :premium_transactions, :order => "created_at"
  has_many :gambit_postbacks, :foreign_key => 'uid'
  has_many :sparechange_postbacks, :foreign_key => 'senderid'
  has_many :visits
  
  after_create :award_new_player_premium_currency

  def self.for( facebook_id, facebook_session=nil )
    u = find_or_create_by_facebook_id( facebook_id.to_i )

    u.store_facebook_session( facebook_session )  unless facebook_session.nil?
    u
  end

  def store_facebook_session( facebook_session )
    return if facebook_session.nil?

    if session_id != facebook_session.session_key
      update_attribute( :session_id, facebook_session.session_key )
    end

    @facebook_session = facebook_session
  end

  def facebook_session
    @facebook_session ||= recreate_facebook_session
  end

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
  
  def award_new_player_premium_currency
    NewPlayerTransaction.record( self, 100 )
  end

  def full_name
  end
  
end
