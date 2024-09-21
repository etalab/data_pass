class BulkAuthorizationRequestUpdate < ApplicationRecord
  validates :authorization_definition_uid, presence: true
  validates :reason, presence: true
  validates :application_date, presence: true
  validate :authorization_definition_exists

  def authorization_definition_exists
    return if AuthorizationDefinition.exists?(id: authorization_definition_uid)

    errors.add(:authorization_definition_uid, :invalid)
  end

  def reason
    format(self[:reason], humanized_application_date: application_date.to_date.strftime('%d/%m/%Y'))
  end

  def authorization_definition
    AuthorizationDefinition.find(authorization_definition_uid)
  end
end
