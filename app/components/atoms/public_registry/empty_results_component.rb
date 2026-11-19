class Atoms::PublicRegistry::EmptyResultsComponent < ApplicationComponent
  REASONS = %i[no_match no_match_filtered no_wallet_entry].freeze

  def initialize(reason: :no_match)
    raise ArgumentError, "reason must be one of #{REASONS}" unless REASONS.include?(reason)

    @reason = reason
  end

  def call
    tag.p(t(".#{@reason}"))
  end
end
