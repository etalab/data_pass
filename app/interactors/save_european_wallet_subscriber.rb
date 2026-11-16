class SaveEuropeanWalletSubscriber < ApplicationInteractor
  def call
    return if attempt_save
    return if adopt_concurrent_subscriber && attempt_save

    context.fail!
  end

  private

  def subscriber
    context.subscriber
  end

  def attempt_save
    valid_subscriber? && subscriber.save
  rescue ActiveRecord::RecordNotUnique
    subscriber.errors.add(:email, :taken)
    false
  end

  def valid_subscriber?
    subscriber.valid?
    subscriber.errors.add(:profile, :inclusion) if profile_no_longer_offered?
    subscriber.errors.none?
  end

  def profile_no_longer_offered?
    context.registry_open && subscriber.organization?
  end

  def adopt_concurrent_subscriber
    return false unless subscriber.new_record? && subscriber.errors.of_kind?(:email, :taken)

    profile = subscriber.profile
    context.subscriber = EuropeanWalletSubscriber.find_by!(email: subscriber.email)
    context.subscriber.profile = profile
    true
  end
end
