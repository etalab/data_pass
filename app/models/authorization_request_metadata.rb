class AuthorizationRequestMetadata
  include ActiveModel::Validations

  NAMESPACES = %w[api datapass].freeze

  attr_reader :content

  validate :content_must_be_an_object
  validate :namespaces_must_be_known, if: :object?
  validate :namespaces_must_be_valid, if: :object?

  def initialize(content)
    @content = content
  end

  private

  def object?
    content.is_a?(Hash)
  end

  def content_must_be_an_object
    errors.add(:content, :not_an_object) unless object?
  end

  def namespaces_must_be_known
    unknown_namespace_names.each { |namespace| errors.add(:content, :unknown_namespace, namespace:) }
  end

  def namespaces_must_be_valid
    known_namespaces.each do |name, namespace|
      next if namespace.valid?

      namespace.errors.each do |error|
        errors.add(:content, :"#{error.attribute}_#{error.type}", namespace: name, **error.options)
      end
    end
  end

  def unknown_namespace_names
    content.keys.map(&:to_s) - NAMESPACES
  end

  def known_namespaces
    content.transform_keys(&:to_s).slice(*NAMESPACES).transform_values { |namespace_content| Namespace.new(namespace_content) }
  end
end
