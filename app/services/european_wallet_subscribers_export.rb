require 'csv'

class EuropeanWalletSubscribersExport
  HEADERS = %w[email profil date_inscription lien_desinscription].freeze

  def initialize(profile:, host: DatapassHost.url)
    @profile = profile
    @host = host
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADERS
      subscribers.find_each { |subscriber| csv << row(subscriber) }
    end
  end

  private

  attr_reader :profile, :host

  def subscribers
    EuropeanWalletSubscriber.where(profile: profile_key).order(:created_at)
  end

  def profile_key
    EuropeanWalletSubscriber.profiles.fetch(profile)
  end

  def row(subscriber)
    [
      subscriber.email,
      subscriber.external_profile,
      subscriber.created_at.to_date.iso8601,
      unsubscribe_url(subscriber),
    ]
  end

  def unsubscribe_url(subscriber)
    Rails.application.routes.url_helpers.european_wallet_unsubscription_url(
      token: subscriber.generate_token_for(:unsubscribe),
      host:,
    )
  end
end
