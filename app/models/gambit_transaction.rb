
class GambitTransaction < PremiumTransaction

  def self.record( postback_params )
    transaction do
      gp = GambitPostback.create_from_request_params( postback_params )
      u = gp.user

      gt = create!( :user            => u,
                    :total_plays     => u.total_plays,
                    :gambit_postback => gp,
                    :change_amount   => gp.amount,
                    :before_amount   => u.premium_currency,
                    :after_amount    => u.premium_currency + gp.amount )

      u.premium_currency += gp.amount
      u.save!

      gt
    end
  end

end

