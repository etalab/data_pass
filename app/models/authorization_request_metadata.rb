class AuthorizationRequestMetadata
  include ActiveModel::Validations

  NAMESPACES = %w[api datapass].freeze

  attr_reader :content

  validate :content_must_be_an_object
  validates :content, length: { maximum: 20 }, if: :object?
  validate :entries_must_be_valid, if: :object?

  def initialize(content)
    @content = content
  end

  def entries
    content.map { |key, value| Entry.new(key.to_s, value) }
  end

  private

  def object?
    content.is_a?(Hash)
  end

  def content_must_be_an_object
    errors.add(:content, :not_an_object) unless object?
  end

  def entries_must_be_valid
    entries.reject(&:valid?).each do |entry|
      entry.errors.each { |error| errors.add(error.attribute, error.type, key: entry.key, **error.options) }
    end
  end
end
