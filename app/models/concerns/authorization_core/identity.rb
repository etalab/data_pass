module AuthorizationCore::Identity
  extend ActiveSupport::Concern

  included do
    class_attribute :identity_sources, default: []
  end

  class_methods do
    def identity_from(*sources)
      self.identity_sources = sources
      attribute_names = sources.flat_map(&:attribute_names).uniq

      store_accessor :data, *attribute_names.map { |attribute| :"identity_#{attribute}" }, :identity_retrieved_at
    end
  end

  def copy_identity_from_sources
    return if organization.nil?

    copied = identity_sources.map { |source| source.new.attributes(organization) }.reduce({}, :merge)

    self.data = data.merge(
      copied.transform_keys { |attribute| "identity_#{attribute}" },
      'identity_retrieved_at' => Time.zone.now.iso8601
    )
  end

  def identity_retrieved?
    identity_retrieved_at.present? && identity_missing_sources.exclude?(try(:identity_source))
  end

  def identity_pending?
    identity_sources.map(&:pending_source).include?(try(:identity_source))
  end

  def copy_loaded_identity!
    return unless identity_pending?

    copy_identity_from_sources
    save!(validate: false) unless identity_pending?
  end

  def mark_identity_unavailable
    return if identity_retrieved?

    self.data = data.merge('identity_source' => identity_sources.first.unavailable_source)
  end

  def refresh_identity_sources
    identity_sources.map { |source| source.new.refresh(organization) }.all?
  end

  private

  def identity_missing_sources
    identity_sources.flat_map { |source| [source.unavailable_source, source.pending_source] }
  end
end
