class AuthorizationRequestEvent < ApplicationRecord
  NAMES = %w[
    create
    update
    submit
    approve
    request_changes
    refuse

    system_reminder
  ].freeze

  belongs_to :user, optional: true
  belongs_to :entity, polymorphic: true

  validates :user, presence: true, unless: -> { name.try(:starts_with?, 'system_') }
  validates :name, inclusion: { in: NAMES }

  validate :entity_type_is_authorized

  # rubocop:disable Metrics/CyclomaticComplexity
  def entity_type_is_authorized
    return if name.blank? || entity_type.blank?

    return if name == 'refuse' && entity_type == 'DenialOfAuthorization'
    return if name == 'request_changes' && entity_type == 'InstructorModificationRequest'
    return if entity_type == 'AuthorizationRequest'

    errors.add(:entity_type, :invalid)
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def authorization_request
    entity.authorization_request
  rescue NoMethodError
    entity
  end
end
