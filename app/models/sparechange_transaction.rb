
class SparechangeTransaction < PremiumTransaction

  def self.record( postback_params )
    transaction do
      sp = SparechangePostback.create_from_request_params( postback_params )
      u = sp.user

      st = create!( :user                 => u,
                    :total_plays          => u.total_plays,
                    :sparechange_postback => sp,
                    :change_amount        => sp.points,
                    :before_amount        => u.premium_currency,
                    :after_amount         => u.premium_currency + sp.points )

      u.premium_currency += sp.points
      u.save!

      st
    end
  end

end

