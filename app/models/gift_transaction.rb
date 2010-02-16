
class GiftTransaction < PremiumTransaction

  def self.record( user, amount )
    transaction do
      gt = create!( :user          => user,
                    :total_plays   => user.total_plays,
                    :change_amount => amount,
                    :before_amount => user.premium_currency,
                    :after_amount  => user.premium_currency + amount )

        user.premium_currency += amount
        user.save!

      gt
    end
  end

end

