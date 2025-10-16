class MessageTemplate < ApplicationRecord
  enum :template_type, { refusal: 0, modification_request: 1 }

  validates :authorization_definition_uid, presence: true
  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true
  validates :template_type, presence: true
  validate :authorization_definition_exists
  validate :variables_are_valid
  validate :maximum_three_templates_per_type

  scope :for_authorization_definition, ->(uid) { where(authorization_definition_uid: uid) }
  scope :for_type, ->(type) { where(template_type: type) }

  def authorization_definition_exists
    return if AuthorizationDefinition.exists?(id: authorization_definition_uid)

    errors.add(:authorization_definition_uid, :invalid)
  end

  def authorization_definition
    @authorization_definition ||= AuthorizationDefinition.find(authorization_definition_uid)
  end

  def variables_are_valid
    return if content.blank?
    return unless AuthorizationDefinition.exists?(id: authorization_definition_uid)
    return if MessageTemplateInterpolator.new(content).valid?(authorization_definition.authorization_request_class.new(id: -1))

    errors.add(:content, :invalid_variables)
  end

  def maximum_three_templates_per_type
    return if authorization_definition_uid.blank? || template_type.blank?

    existing_templates = MessageTemplate
      .where(authorization_definition_uid:, template_type:)
      .where.not(id:)
      .count

    return if existing_templates < 3

    errors.add(:base, :max_templates_reached, count: 3)
  end
end
