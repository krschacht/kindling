
class NewPlayerTransaction < PremiumTransaction

  def self.record( user, initial_premium )
    transaction do
      nt = create!( :user          => user,
                    :total_plays   => user.total_plays,
                    :change_amount => initial_premium,
                    :before_amount => 0,
                    :after_amount  => initial_premium )

      user.premium_currency = initial_premium
      user.save!

      nt
    end
  end

end

