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

  TYPES = TYPES_BY_ACTION.values.flatten.freeze

  attr_reader :suppressed_types, :mandatory_types

  def self.allow_all
    new
  end

  def self.for_api_call(data_provider:, action:, notifications:)
    return allow_all unless notifications_disabled?(notifications)

    types = TYPES_BY_ACTION.fetch(action.to_s, [])
    optional_types = Array(data_provider&.optional_notification_types) & types

    new(suppressed_types: optional_types, mandatory_types: types - optional_types)
  end

  def self.notifications_disabled?(notifications)
    !notifications.nil? && !ActiveModel::Type::Boolean.new.cast(notifications)
  end

  def initialize(suppressed_types: [], mandatory_types: [])
    @suppressed_types = suppressed_types
    @mandatory_types = mandatory_types
  end

  def suppress?(type)
    suppressed_types.include?(type.to_s)
  end

  def suppressed_any?
    suppressed_types.any?
  end

  def warnings
    return [] if mandatory_types.empty?

    [{
      title: I18n.t('notification_policy.mandatory_notifications.title'),
      detail: I18n.t('notification_policy.mandatory_notifications.detail', types: mandatory_types.join(', '))
    }]
  end
end
