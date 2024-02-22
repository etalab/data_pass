class Authorization < ApplicationRecord
  validates :data, presence: true

  belongs_to :applicant,
    class_name: 'User',
    inverse_of: :authorizations_as_applicant

  belongs_to :request,
    class_name: 'AuthorizationRequest',
    inverse_of: :authorizations,
    dependent: :destroy

  has_one :organization,
    through: :request

  delegate :name, to: :request

  def kind
    request.type.underscore
  end

  def request_as_validated
    request_as_validated = request.dup
    request_as_validated.id = request.id
    request_as_validated.data = data
    request_as_validated.state = 'validated'
    request_as_validated
  end

  def latest?
    request.latest_authorization == self
  end

  def latest
    request.latest_authorization
  end

  def authorization_request
    request
  end
end
