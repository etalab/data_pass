module NamespacedMetadata
  extend ActiveSupport::Concern

  included do
    validate :metadata_must_be_valid
  end

  def metadata_for(namespace)
    metadata.fetch(namespace.to_s, {})
  end

  def assign_metadata(namespace, content)
    self.metadata = if content.blank?
                      metadata.except(namespace.to_s)
                    else
                      metadata.merge(namespace.to_s => content.to_h.stringify_keys)
                    end
  end

  private

  def metadata_must_be_valid
    return errors.add(:metadata, :not_an_object) unless metadata.is_a?(Hash)

    metadata.each { |namespace, content| validate_metadata_namespace(namespace.to_s, content) }
  end

  def validate_metadata_namespace(namespace, content)
    return errors.add(:metadata, :unknown_namespace, namespace:) unless AuthorizationRequestMetadata::NAMESPACES.include?(namespace)

    namespace_metadata = AuthorizationRequestMetadata.new(content)
    return if namespace_metadata.valid?

    namespace_metadata.errors.each do |error|
      errors.add(:metadata, :"#{error.attribute}_#{error.type}", namespace:, **error.options)
    end
  end
end
