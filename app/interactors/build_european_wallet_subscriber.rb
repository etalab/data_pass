class BuildEuropeanWalletSubscriber < ApplicationInteractor
  def call
    context.subscriber = EuropeanWalletSubscriber.find_or_initialize_by(email: context.email.to_s)
    context.subscriber.profile = context.profile
  end
end
