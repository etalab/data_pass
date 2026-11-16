require 'csv'

class EuropeanWalletSubscribersExport
  HEADERS = %w[email profil date_inscription].freeze
  FORMULA_TRIGGERS = ['=', '+', '-', '@', "\t", "\r"].freeze

  def initialize(profile:)
    @profile = profile
  end

  def to_csv
    CSV.generate do |csv|
      csv << HEADERS
      subscribers.find_each { |subscriber| csv << row(subscriber).map { |cell| neutralize_formula(cell) } }
    end
  end

  private

  attr_reader :profile

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
    ]
  end

  def neutralize_formula(cell)
    cell.start_with?(*FORMULA_TRIGGERS) ? "'#{cell}" : cell
  end
end
