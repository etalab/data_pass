class NotificationPolicy
  TYPES_BY_ACTION = {
    'submit' => %w[
      applicant_submit_receipt
      instructors_new_request
    ],
    'approve' => %w[
      applicant_approval
      gdpr_contacts_approval
      france_connect_team
      linked_france_connect
      dgfip_approval
      hubee_qf_approval
      hubee_business_admin
      produits_dinum_convention
    ]
  }.freeze

  DISABLED_VALUES = [false, 'false'].freeze
  ENABLED_VALUES = [true, 'true'].freeze

  attr_reader :suppressed_types, :kept_types

  def self.allow_all
    new
  end

  def self.for_api_call(data_provider:, action:, notifications:)
    return allow_all unless notifications_disabled?(notifications)

    optional_types = Array(data_provider&.optional_notification_types) & TYPES_BY_ACTION.fetch(action.to_s, [])

    new(requested: true, optional_types:)
  end

  def self.notifications_disabled?(notifications)
    DISABLED_VALUES.include?(notifications)
  end

  def self.valid_value?(notifications)
    notifications.nil? || DISABLED_VALUES.include?(notifications) || ENABLED_VALUES.include?(notifications)
  end

  def initialize(requested: false, optional_types: [])
    @requested = requested
    @optional_types = optional_types
    @suppressed_types = []
    @kept_types = []
  end

  def deliver(type)
    type = type.to_s

    if @optional_types.include?(type)
      suppressed_types << type unless suppressed_types.include?(type)
    else
      kept_types << type if @requested && kept_types.exclude?(type)
      yield
    end
  end

  def suppressed_any?
    suppressed_types.any?
  end

  def warnings
    return [] if kept_types.empty?

    [{
      title: I18n.t('notification_policy.mandatory_notifications.title'),
      detail: I18n.t('notification_policy.mandatory_notifications.detail', types: kept_types.join(', '))
    }]
  end
end
