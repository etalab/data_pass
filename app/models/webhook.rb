class Webhook < ApplicationRecord
  VALID_EVENTS = %w[
    create
    update
    transfer
    submit
    approve
    refuse
    request_changes
    revoke
    archive
    reopen
    cancel_reopening
  ].freeze

  has_many :calls, class_name: 'WebhookCall', dependent: :destroy

  encrypts :secret, deterministic: false

  validates :authorization_definition_id, presence: true
  validates :url, presence: true
  validates :secret, presence: true
  validates :events, presence: true
  validate :url_must_be_valid
  validate :events_must_be_array_and_not_empty
  validate :events_must_be_valid
  validate :authorization_definition_must_exist

  scope :active, -> { where(enabled: true, validated: true) }
  scope :active_for_event, lambda { |event_name, authorization_definition_id|
    active
      .where(authorization_definition_id: authorization_definition_id)
      .select { |webhook| webhook.listens_to?(event_name) }
  }

  def self.valid_events
    VALID_EVENTS
  end

  def listens_to?(event_name)
    events.include?(event_name.to_s)
  end

  def activate!
    update!(enabled: true)
  end

  def deactivate!
    update!(enabled: false)
  end

  def mark_as_valid!
    update!(validated: true)
  end

  def definition
    @definition ||= AuthorizationDefinition.find(authorization_definition_id)
  end

  private

  def url_must_be_valid
    URI.parse(url)
  rescue URI::InvalidURIError
    errors.add(:url, 'must be a valid URL')
  end

  def events_must_be_array_and_not_empty
    return if events.is_a?(Array) && events.any?

    errors.add(:events, 'doit contenir au moins un événement')
  end

  def events_must_be_valid
    return unless events.is_a?(Array)

    invalid_events = events - VALID_EVENTS
    return if invalid_events.empty?

    errors.add(:events, "contient des événements invalides : #{invalid_events.join(', ')}")
  end

  def authorization_definition_must_exist
    return if authorization_definition_id.blank?
    return if AuthorizationDefinition.exists?(id: authorization_definition_id)

    errors.add(:authorization_definition_id, 'ne correspond à aucune définition d\'autorisation existante')
  end
end
