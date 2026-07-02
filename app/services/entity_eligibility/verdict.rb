class EntityEligibility::Verdict
  STATUSES = %i[eligible likely_eligible likely_ineligible ineligible unknown].freeze

  attr_reader :status, :reason

  def self.unknown
    new(status: :unknown)
  end

  def initialize(status:, reason: nil)
    raise ArgumentError, "unknown status: #{status}" unless STATUSES.include?(status)

    @status = status
    @reason = reason
  end

  STATUSES.each do |candidate|
    define_method(:"#{candidate}?") { status == candidate }
  end
end
