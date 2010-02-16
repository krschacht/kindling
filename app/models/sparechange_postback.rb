
require 'digest/md5'

class SparechangePostback < ActiveRecord::Base

  belongs_to :user, :foreign_key => 'senderid', :primary_key => 'facebook_id'
  belongs_to :premium_transaction

  validates_presence_of :user

  attr_accessor :signature1
  validates_confirmation_of :signature1

  VALID_PARAMS = %w( senderid points amount txid appid network signature1 )

  def self.create_from_request_params( params )
    down = {}
    params.each { |k,v| down[k.to_s.downcase] = v }

    create!( down.reject { |k,v| ! VALID_PARAMS.include?( k ) } )
  end

  def signature1_confirmation
    Digest::MD5.hexdigest( 
      [Sparechange.secret_key, txid, senderid, amount, points].join )
  end

end

