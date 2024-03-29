class AuthorizationRequestEvent < ApplicationRecord
  NAMES = %w[
    create
    update
    submit
    approve
    request_changes
    refuse
    archive
    reopen

    applicant_message
    instructor_message

    system_reminder
  ].freeze

  belongs_to :user, optional: true
  belongs_to :entity, polymorphic: true

  validates :user, presence: true, unless: -> { name.try(:starts_with?, 'system_') }
  validates :name, inclusion: { in: NAMES }

  validate :entity_type_is_authorized

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
  def entity_type_is_authorized
    return if name.blank? || entity_type.blank?

    return if name == 'refuse' && entity_type == 'DenialOfAuthorization'
    return if name == 'request_changes' && entity_type == 'InstructorModificationRequest'
    return if name == 'submit' && entity_type == 'AuthorizationRequestChangelog'
    return if %w[approve reopen].include?(name) && entity_type == 'Authorization'
    return if %w[applicant_message instructor_message].include?(name) && entity_type == 'Message'
    return if %w[approve refuse request_changes].exclude?(name) && entity_type == 'AuthorizationRequest'

    errors.add(:entity_type, :invalid)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity

  def authorization_request
    entity.authorization_request
  rescue NoMethodError
    entity
  end
end
