class AuthorizationRequestEvent < ApplicationRecord
  NAMES = %w[
    approve
    archive
    create
    refuse
    request_changes
    revoke
    submit
    update
    transfer

    copy

    reopen
    cancel_reopening

    applicant_message
    instructor_message

    admin_update
    bulk_update

    system_reminder
    system_archive
    system_import
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
    return if name == 'revoke' && entity_type == 'RevocationOfAuthorization'
    return if name == 'request_changes' && entity_type == 'InstructorModificationRequest'
    return if name == 'transfer' && entity_type == 'AuthorizationRequestTransfer'
    return if name == 'cancel_reopening' && entity_type == 'AuthorizationRequestReopeningCancellation'
    return if %w[submit admin_update].include?(name) && entity_type == 'AuthorizationRequestChangelog'
    return if %w[approve reopen].include?(name) && entity_type == 'Authorization'
    return if %w[applicant_message instructor_message].include?(name) && entity_type == 'Message'
    return if %w[approve refuse request_changes revoke].exclude?(name) && entity_type == 'AuthorizationRequest'
    return if %w[bulk_update].include?(name) && entity_type == 'BulkAuthorizationRequestUpdate'

    errors.add(:entity_type, :invalid)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity

  def authorization_request
    entity.authorization_request
  rescue NoMethodError
    entity
  end
end
