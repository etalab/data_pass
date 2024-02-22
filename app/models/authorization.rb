class Authorization < ApplicationRecord
  validates :data, presence: true

  belongs_to :applicant,
    class_name: 'User',
    inverse_of: :authorizations_as_applicant

  belongs_to :authorization_request

  has_one :organization,
    through: :authorization_request

  delegate :name, to: :authorization_request

  def kind
    authorization_request.type.underscore
  end

  def authorization_request_as_validated
    authorization_request_as_validated = authorization_request.dup
    authorization_request_as_validated.data = data
    authorization_request_as_validated.state = 'validated'
    authorization_request_as_validated
  end
end
