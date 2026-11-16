class EuropeanWalletSubscribersPurge
  def initialize(profile:)
    @profile = EuropeanWalletSubscriber.profiles.fetch(profile)
  end

  def call
    EuropeanWalletSubscriber.where(profile: @profile).delete_all
  end
end
