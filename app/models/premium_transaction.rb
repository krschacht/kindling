class PremiumTransaction < ActiveRecord::Base

  belongs_to :user
  has_one :gambit_postback
  has_one :sparechange_postback
#  has_one :item

  def self.processor_types
    @types ||= [GambitTransaction, SparechangeTransaction]
  end    

  def self.types
    # This is a list of models that must exist
    @types ||= [NewPlayerTransaction, GiftTransaction]
  end

  named_scope :on_day,        lambda { |day|    { :conditions => ["date(premium_transactions.created_at) = ?", day ] } }
  named_scope :on_month,      lambda { |mon_year|  { :conditions => 
                ["year(premium_transactions.created_at) = ? AND month(premium_transactions.created_at) = ?", 
                    mon_year.split('-').first,
                    mon_year.split('-').second ] } }
  named_scope :on_year_month, lambda { |year,mon|  { :conditions => 
                ["year(premium_transactions.created_at) = ? AND month(premium_transactions.created_at) = ?", year, mon ] } }
  named_scope :from_processors,   :conditions => { :type => processor_types.map { |t| t.name } }
  named_scope :source_txns,       :conditions => ["change_amount > 0"]
  named_scope :sink_txns,         :conditions => ["change_amount < 0"]
  named_scope :sources,           :group => :type, 
                                  :select => "type, sum(change_amount) as sum_change_amount",
                                  :conditions => ["change_amount > 0"],
                                  :order => 'sum_change_amount DESC'
  named_scope :sinks,             :group => :type, 
                                  :select => "type, sum(change_amount) as sum_change_amount",
                                  :conditions => ["change_amount < 0"],
                                  :order => 'sum_change_amount ASC'

end

