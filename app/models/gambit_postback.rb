
require 'digest/md5'

class GambitPostback < ActiveRecord::Base

  belongs_to :user, :foreign_key => 'uid'
  belongs_to :premium_transaction

  validates_presence_of :user

  attr_accessor :sig
  validates_confirmation_of :sig

  VALID_PARAMS = %w( ocid uid amount time oid title subid1 subid2 subid3 sig )

  def self.create_from_request_params( params )
    create!( params.reject { |k,v| ! VALID_PARAMS.include?( k ) } )
  end

  def sig_confirmation
    Digest::MD5.hexdigest( [uid, amount, time, oid, Gambit.secret_key].join )
  end
end

