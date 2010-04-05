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

	ENERGY_REFILL_RATE  = 60

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

	def played!
	  self.total_plays   += 1
	  self.last_played_at = Time.now.utc
	end
  
  ## Energy methods
  	
	def energy_earned
	  energy = ( Time.now.utc - self.last_energy_at ).seconds / ENERGY_REFILL_RATE
    [ energy.floor, self.energy_max - self.energy ].min
	end
	
	def energy_full?
	  self.energy == self.energy_max
	end
	
	def seconds_till_more_energy
    return 0  if energy_full?
    
    ( ENERGY_REFILL_RATE - ( Time.now.utc - self.last_energy_at ).seconds ).to_i
	end
	
	# If you call this w/o an amount, then it awards the user energy they've
	# earned as a result of the timer
	def adjust_energy( amt = nil )
    amt ||= energy_earned

    self.energy        += amt	    
    self.energy         = self.energy_max  if self.energy > self.energy_max
    self.energy         = 0                if self.energy < 0    

    self.last_energy_at = Time.now.utc     unless amt.nil?
	end

	def adjust_energy!( amt = nil )
	  adjust_energy( amt )
	  self.save
	end
	
end
