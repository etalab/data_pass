class AuthorizationRequestMetadata::Entry
  include ActiveModel::Validations

  SAFE_NUMBER_LIMIT = (2**53) - 1

  attr_reader :key, :value

  validates :key, length: { maximum: 40 }, format: { with: /\A[a-zA-Z0-9_.-]+\z/ }
  validates :value, length: { maximum: 500 }, format: { without: /\u0000/ }, if: :text?
  validate :value_must_be_scalar
  validate :number_must_stay_within_safe_limit, if: :number?

  def initialize(key, value)
    @key = key
    @value = value
  end

  private

  def value_must_be_scalar
    errors.add(:value, :not_scalar) unless scalar?
  end

  def number_must_stay_within_safe_limit
    errors.add(:value, :out_of_range, count: SAFE_NUMBER_LIMIT) if value.abs > SAFE_NUMBER_LIMIT
  end

  def scalar?
    text? || number? || boolean?
  end

  def text?
    value.is_a?(String)
  end

  def number?
    value.is_a?(Numeric) && value.finite?
  end

  def boolean?
    [true, false].include?(value)
  end
end
