class AuthorizationRequestMetadata::Entry
  include ActiveModel::Validations

  attr_reader :key, :value

  validates :key, length: { maximum: 40 }, format: { with: /\A[a-zA-Z0-9_.-]+\z/ }
  validates :value, length: { maximum: 500 }, if: -> { value.is_a?(String) }
  validate :value_must_be_scalar

  def initialize(key, value)
    @key = key
    @value = value
  end

  private

  def value_must_be_scalar
    errors.add(:value, :not_scalar) unless scalar?
  end

  def scalar?
    value.is_a?(String) || (value.is_a?(Numeric) && value.finite?) || value == true || value == false
  end
end
