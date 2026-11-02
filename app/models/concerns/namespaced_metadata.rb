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
    validated_metadata = AuthorizationRequestMetadata.new(metadata)
    return if validated_metadata.valid?

    validated_metadata.errors.each { |error| errors.add(:metadata, error.type, **error.options) }
  end
end
